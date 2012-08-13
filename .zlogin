# Evaluate when login

(pgrep 'emacs-24\.1' > /dev/null) || emacs-24.1 --daemon
eval `ssh-agent`

# pgrep installation
# % brew install proctools # as root
