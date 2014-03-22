function __promptline_git_status {
  [[ $(git rev-parse --is-inside-work-tree 2>/dev/null) == true ]] || return 1

  local added_symbol="+"
  local removed_symbol="-"
  local unmerged_symbol="x"
  local modified_symbol="~"
  local clean_symbol="✔"
  local untracked_symbol="?"

  local ahead_symbol="↑"
  local behind_symbol="↓"

  local unmerged_count=0 modified_count=0 untracked_count=0 added_count=0 removed_count=0 is_clean=""

  set -- $(git rev-list --left-right --count @{upstream}...HEAD 2>/dev/null)
  local behind_count=$1
  local ahead_count=$2

  # Added (A), Copied (C), Deleted (D), Modified (M), Renamed (R), changed (T), Unmerged (U), Unknown (X), Broken (B)
  while read line; do
    case "$line" in
      AM*) added_count=$(( $added_count + 1 )) ;;
      RM*) modified_count=$(( $modified_count + 1 )) ;;
      D*) removed_count=$(( $removed_count + 1 )) ;;
      M*) modified_count=$(( $modified_count + 1 )) ;;
      U*) unmerged_count=$(( $unmerged_count + 1 )) ;;
      A*) added_count=$(( $added_count + 1 )) ;;
      ?*) untracked_count=$(( $untracked_count + 1 )) ;;
    esac
  done < <(git status --porcelain)

  if [ $(( removed_count + unmerged_count + modified_count + untracked_count + added_count )) -eq 0 ]; then
    is_clean=1
  fi

  local leading_whitespace=""
  [[ $ahead_count -gt 0 ]]         && { printf "%s" "$leading_whitespace$ahead_symbol$ahead_count"; leading_whitespace=" "; }
  [[ $behind_count -gt 0 ]]        && { printf "%s" "$leading_whitespace$behind_symbol$behind_count"; leading_whitespace=" "; }
  [[ $modified_count -gt 0 ]]      && { printf "%s" "$leading_whitespace$modified_symbol$modified_count"; leading_whitespace=" "; }
  [[ $unmerged_count -gt 0 ]]      && { printf "%s" "$leading_whitespace$unmerged_symbol$unmerged_count"; leading_whitespace=" "; }
  [[ $added_count -gt 0 ]]         && { printf "%s" "$leading_whitespace$added_symbol$added_count"; leading_whitespace=" "; }
  [[ $removed_count -gt 0 ]]         && { printf "%s" "$leading_whitespace$removed_symbol$removed_count"; leading_whitespace=" "; }
  [[ $untracked_count -gt 0 ]] && { printf "%s" "$leading_whitespace$untracked_symbol$untracked_count"; leading_whitespace=" "; }
  [[ $is_clean -gt 0 ]]            && { printf "%s" "$leading_whitespace$clean_symbol"; leading_whitespace=" "; }
}

