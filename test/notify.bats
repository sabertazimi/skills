#!/usr/bin/env bats
# Tests for hooks/notify.sh

setup() {
    bats_load_library bats-support
    bats_load_library bats-assert
    load test_helper/common-setup
    _common_setup
}

# Helper: run notify.sh with JSON on stdin and return captured notify-send args
run_notify() {
    local json="$1"
    : > "$NOTIFY_LOG"
    run bash -c "printf '%s' '$json' | '$NOTIFY_SH'"
}

# =============================================================================
# Basic functionality
# =============================================================================

@test "Stop event: forwards last_assistant_message to notify-send" {
    run_notify '{"hook_event_name":"Stop","last_assistant_message":"Build succeeded"}'
    [ "$status" -eq 0 ]
    local log
    log="$(cat "$NOTIFY_LOG")"
    [[ "$log" == *"Build succeeded"* ]]
}

@test "Stop event: includes title 'Claude Code'" {
    run_notify '{"hook_event_name":"Stop","last_assistant_message":"done"}'
    local log
    log="$(cat "$NOTIFY_LOG")"
    [[ "$log" == *"Claude Code"* ]]
}

@test "Notification event: forwards .message to notify-send" {
    run_notify '{"hook_event_name":"Notification","message":"Needs your approval"}'
    [ "$status" -eq 0 ]
    local log
    log="$(cat "$NOTIFY_LOG")"
    [[ "$log" == *"Needs your approval"* ]]
}

@test "Unknown event: uses .message field" {
    run_notify '{"hook_event_name":"Custom","message":"Something happened"}'
    [ "$status" -eq 0 ]
    local log
    log="$(cat "$NOTIFY_LOG")"
    [[ "$log" == *"Something happened"* ]]
}

@test "Stop event with null message: falls back to 'Task completed'" {
    run_notify '{"hook_event_name":"Stop","last_assistant_message":null}'
    [ "$status" -eq 0 ]
    local log
    log="$(cat "$NOTIFY_LOG")"
    [[ "$log" == *"Task completed"* ]]
}

@test "Notification event with missing message: falls back to 'Needs your input'" {
    run_notify '{"hook_event_name":"Notification"}'
    [ "$status" -eq 0 ]
    local log
    log="$(cat "$NOTIFY_LOG")"
    [[ "$log" == *"Needs your input"* ]]
}

@test "jq missing: fallback path for Stop event" {
    # Remove jq by filtering it out of PATH, keep fake notify-send
    local no_jq_path=""
    local IFS=':'
    for dir in $PATH; do
        if [ ! -x "${dir}/jq" ]; then
            no_jq_path="${no_jq_path:+$no_jq_path:}${dir}"
        fi
    done
    PATH="$no_jq_path"
    export PATH

    : > "$NOTIFY_LOG"
    run bash -c "printf '%s' '{\"hook_event_name\":\"Stop\",\"last_assistant_message\":\"ignored\"}' | '$NOTIFY_SH'"
    [ "$status" -eq 0 ]
    local log
    log="$(cat "$NOTIFY_LOG")"
    [[ "$log" == *"Task completed"* ]]
}

@test "jq missing: fallback path for Notification event" {
    local no_jq_path=""
    local IFS=':'
    for dir in $PATH; do
        if [ ! -x "${dir}/jq" ]; then
            no_jq_path="${no_jq_path:+$no_jq_path:}${dir}"
        fi
    done
    PATH="$no_jq_path"
    export PATH

    : > "$NOTIFY_LOG"
    run bash -c "printf '%s' '{\"hook_event_name\":\"Notification\",\"message\":\"ignored\"}' | '$NOTIFY_SH'"
    [ "$status" -eq 0 ]
    local log
    log="$(cat "$NOTIFY_LOG")"
    [[ "$log" == *"Needs your input"* ]]
}

# =============================================================================
# Character set tests
# =============================================================================

@test "CJK characters: Chinese, Japanese, Korean" {
    run_notify '{"hook_event_name":"Stop","last_assistant_message":"你好世界こんにちは안녕하세요"}'
    [ "$status" -eq 0 ]
    local log
    log="$(cat "$NOTIFY_LOG")"
    [[ "$log" == *"你好世界こんにちは안녕하세요"* ]]
}

@test "Cyrillic and Arabic characters" {
    run_notify '{"hook_event_name":"Stop","last_assistant_message":"Привет мир مرحبا بالعالم"}'
    [ "$status" -eq 0 ]
    local log
    log="$(cat "$NOTIFY_LOG")"
    [[ "$log" == *"Привет мир مرحبا بالعالم"* ]]
}

@test "Emoji: multi-byte emoji" {
    run_notify '{"hook_event_name":"Stop","last_assistant_message":"🚀🔥⚡✨👨‍💻🎯"}'
    [ "$status" -eq 0 ]
    local log
    log="$(cat "$NOTIFY_LOG")"
    [[ "$log" == *"🚀🔥⚡✨👨‍💻🎯"* ]]
}

@test "Mathematical Unicode symbols" {
    run_notify '{"hook_event_name":"Stop","last_assistant_message":"∑∫∞±×÷√∀∃∈∩∪∧∨¬⇒≠≤≥"}'
    [ "$status" -eq 0 ]
    local log
    log="$(cat "$NOTIFY_LOG")"
    [[ "$log" == *"∑∫∞±×÷√∀∃∈∩∪∧∨¬⇒≠≤≥"* ]]
}

@test "HTML/XML special characters" {
    run_notify '{"hook_event_name":"Stop","last_assistant_message":"<div class=\"test\">a & b</div>"}'
    [ "$status" -eq 0 ]
    local log
    log="$(cat "$NOTIFY_LOG")"
    [[ "$log" == *'<div class="test">a & b</div>'* ]]
}

@test "Shell special characters in message" {
    # Use heredoc to avoid shell expansion of $HOME inside double quotes
    local json
    json=$(cat << 'ENDJSON'
{"hook_event_name":"Stop","last_assistant_message":"echo $HOME | grep test || true"}
ENDJSON
)
    : > "$NOTIFY_LOG"
    run bash -c "printf '%s' '$json' | '$NOTIFY_SH'"
    [ "$status" -eq 0 ]
    local log
    log="$(cat "$NOTIFY_LOG")"
    [[ "$log" == *"echo \$HOME | grep test || true"* ]]
}

@test "Combining diacritical marks" {
    # jq -r preserves combining characters as-is (NFD), so match the same form
    local msg='éêẽ'
    run_notify "{\"hook_event_name\":\"Stop\",\"last_assistant_message\":\"${msg}\"}"
    [ "$status" -eq 0 ]
    local log
    log="$(cat "$NOTIFY_LOG")"
    # Match the NFD form that jq outputs
    [[ "$log" == *"éêẽ"* ]]
}

@test "Mixed charset: all character types combined" {
    run_notify '{"hook_event_name":"Stop","last_assistant_message":"你好🚀∑∞±<a>&b\\x27c"}'
    [ "$status" -eq 0 ]
    local log
    log="$(cat "$NOTIFY_LOG")"
    [[ "$log" == *"你好🚀∑∞±<a>&b\\x27c"* ]]
}

@test "Long message: truncated to ~200 bytes with sanitize_utf8 cleanup" {
    # Generate a long string (~300 chars of Chinese, 900+ bytes)
    local long_msg=""
    for i in $(seq 1 50); do
        long_msg="${long_msg}你好世界"
    done
    run_notify "{\"hook_event_name\":\"Stop\",\"last_assistant_message\":\"${long_msg}\"}"
    [ "$status" -eq 0 ]
    local log
    log="$(cat "$NOTIFY_LOG")"
    # Message should be present but truncated — verify it starts correctly
    [[ "$log" == *"你好世界你好世界"* ]]
    # And should NOT contain the full 200-char string
    local log_len
    log_len="${#log}"
    [[ "$log_len" -lt 300 ]]
}

@test "Unicode flags and ZWJ sequences" {
    run_notify '{"hook_event_name":"Stop","last_assistant_message":"🏴‍☠️️🏳️‍🌈🇨🇳🇺🇸"}'
    [ "$status" -eq 0 ]
    local log
    log="$(cat "$NOTIFY_LOG")"
    [[ "$log" == *"🇨🇳🇺🇸"* ]]
}
