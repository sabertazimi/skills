#!/usr/bin/env bash
# Shared setup for notify.sh bats tests.
# Provides a fake notify-send that logs its arguments to a file.

_common_setup() {
    # Point to the hooks directory
    NOTIFY_SH="$(cd "$(dirname "$BATS_TEST_FILENAME")/../.." && pwd)/hooks/notify.sh"

    # Create a fake notify-send that logs arguments
    FAKE_BIN="${BATS_TEST_TMPDIR}/bin"
    mkdir -p "$FAKE_BIN"
    NOTIFY_LOG="${BATS_TEST_TMPDIR}/notify-send.log"

    cat > "$FAKE_BIN/notify-send" << EOF
#!/usr/bin/env bash
printf '%s\n' "\$@" >> "${NOTIFY_LOG}"
EOF
    chmod +x "$FAKE_BIN/notify-send"

    # Prepend fake bin so mock shadows the real notify-send
    PATH="$FAKE_BIN:$PATH"
    export PATH
    export NOTIFY_LOG
}
