#!/bin/bash
_aeza_completion() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="reboot delete rename start stop ssh ip list create wait products os limits"
    
    if [[ ${COMP_CWORD} -eq 1 ]]; then
        COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
        return 0
    fi
    
    case "$prev" in
        reboot|delete|rename|start|stop|ssh|ip|wait)
            COMPREPLY=( $(aeza list json 2>/dev/null | jq -r '.[].name' 2>/dev/null) )
            ;;
        create)
            if [[ ${COMP_CWORD} -eq 2 ]]; then
                COMPREPLY=( $(aeza products json 2>/dev/null | jq -r '.[].name' 2>/dev/null) )
            elif [[ ${COMP_CWORD} -eq 3 ]]; then
                COMPREPLY=( $(aeza os json 2>/dev/null | jq -r '.[].id' 2>/dev/null) )
            fi
            ;;
    esac
}
complete -F _aeza_completion aeza
