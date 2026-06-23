# ai-tmux.zsh — shared tmux sessions for claude/codex, mirrored to your phone
# over Tailscale (ssh/mosh in, then ai-join). Source this from your zsh config.

# ai-start NAME [-C dir] [command and flags...]
#   NAME     required, the session name (so you can `ai-join NAME` from the phone)
#   -C dir   working directory the command runs in (default: current dir)
#   rest     command + flags to launch (default: claude)
#
# examples:
#   ai-start riomus                      # claude in $PWD, session "riomus"
#   ai-start riomus -C ~/git/riomus claude --dangerously-skip-permissions
#   ai-start cdx -C ~/git/foo codex --model gpt-5
ai-start() {
  emulate -L zsh
  local name="$1"; shift
  if [[ -z "$name" ]]; then
    print -u2 "usage: ai-start NAME [-C dir] [command and flags...]"
    return 1
  fi

  local dir="$PWD"
  if [[ "$1" == "-C" ]]; then
    dir="$2"; shift 2
  fi
  dir="${dir:A}"                       # resolve to absolute path
  if [[ ! -d "$dir" ]]; then
    print -u2 "ai-start: no such directory: $dir"
    return 1
  fi

  (( $# == 0 )) && set -- claude       # default command

  if tmux has-session -t "=$name" 2>/dev/null; then
    print -u2 "ai-start: session '$name' already exists — attaching to it"
    tmux attach -t "=$name"
    return
  fi

  local cmd="${(j: :)${(@q)@}}"        # re-quote each arg, then join with spaces
  tmux new-session -d -s "$name" -c "$dir"
  tmux send-keys -t "=$name" "$cmd" C-m
  tmux attach -t "=$name"
}

# ai-join [NAME]
#   NAME   attach to the session with this exact name
#   (none) attach to the session that was started in the current directory
ai-join() {
  emulate -L zsh
  local name="$1"

  if [[ -n "$name" ]]; then
    if tmux has-session -t "=$name" 2>/dev/null; then
      tmux attach -t "=$name"
    else
      print -u2 "ai-join: no session named '$name'"
      ai-ls
      return 1
    fi
    return
  fi

  # no name -> couple by directory (match the session's start dir to $PWD)
  local target="${PWD:A}" sname spath
  while IFS=$'\t' read -r sname spath; do
    if [[ "${spath:A}" == "$target" ]]; then
      tmux attach -t "=$sname"
      return
    fi
  done < <(tmux list-sessions -F '#{session_name}	#{session_path}' 2>/dev/null)

  print -u2 "ai-join: no session started in $target"
  ai-ls
  return 1
}

# ai-ls — list running sessions with their start directories
ai-ls() {
  emulate -L zsh
  local out
  out="$(tmux list-sessions -F '  #{session_name}	#{session_path}' 2>/dev/null)"
  if [[ -z "$out" ]]; then
    print -u2 "  (no running sessions)"
  else
    print -u2 "running sessions:"
    print -u2 -- "$out"
  fi
}
