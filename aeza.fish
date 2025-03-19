complete -c aeza -f -n "__fish_use_subcommand" -a "reboot" -d "Reboot a server"
complete -c aeza -f -n "__fish_use_subcommand" -a "delete" -d "Delete a server"
complete -c aeza -f -n "__fish_use_subcommand" -a "rename" -d "Rename a server"
complete -c aeza -f -n "__fish_use_subcommand" -a "start" -d "Start a server"
complete -c aeza -f -n "__fish_use_subcommand" -a "stop" -d "Stop a server"
complete -c aeza -f -n "__fish_use_subcommand" -a "ssh" -d "SSH into a server"
complete -c aeza -f -n "__fish_use_subcommand" -a "ip" -d "Show server IP"
complete -c aeza -f -n "__fish_use_subcommand" -a "list" -d "Reboot a server"
complete -c aeza -f -n "__fish_use_subcommand" -a "create" -d "Create a server"
complete -c aeza -f -n "__fish_use_subcommand" -a "wait" -d "Wait for a server to become active"
complete -c aeza -f -n "__fish_use_subcommand" -a "products" -d "List available products"
complete -c aeza -f -n "__fish_use_subcommand" -a "os" -d "List available operating systems"
complete -c aeza -f -n "__fish_use_subcommand" -a "limits" -d "List resource limits"

function __aeza_is_macos
    test (uname) = "Darwin"
end

function __aeza_cache_file
    set -l type $argv[1]
    echo "$HOME/.cache/aeza/$type.cache"
end

function __aeza_get_file_mtime
    set -l cache_file $argv[1]
    if __aeza_is_macos
        stat -f %m $cache_file 2>/dev/null
    else
        stat -c %Y $cache_file 2>/dev/null
    end
end

function __aeza_cache_expired
    set -l cache_file $argv[1]
    set -l max_age $argv[2]
    if not test -f $cache_file
        mkdir -p (dirname $cache_file)
        return 0
    end
    set -l file_mtime (__aeza_get_file_mtime $cache_file)
    set -l current_time (date +%s)
    if test -z "$file_mtime"
        return 0
    end

    set -l file_age (math $current_time - $file_mtime)
    if test $file_age -gt $max_age
        return 0
    else
        return 1
    end
end

function __aeza_get_servers
    set -l cache_file (__aeza_cache_file "servers")
    set -l cache_time 30

    if __aeza_cache_expired $cache_file $cache_time
        mkdir -p (dirname $cache_file)
        aeza list json 2>/dev/null | jq -r '.[] | "\(.name)\t\(.id)"' > $cache_file 2>/dev/null || echo "" > $cache_file
    end

    cat $cache_file 2>/dev/null || echo ""
end

function __aeza_get_products
    set -l cache_file (__aeza_cache_file "products")
    set -l cache_time 300

    if __aeza_cache_expired $cache_file $cache_time
        mkdir -p (dirname $cache_file)
        aeza products json 2>/dev/null | jq -r '.[] | "\(.name)\t\(.type)"' > $cache_file 2>/dev/null || echo "" > $cache_file
    end

    cat $cache_file 2>/dev/null || echo ""
end

function __aeza_get_os
    set -l cache_file (__aeza_cache_file "os")
    set -l cache_time 300

    if __aeza_cache_expired $cache_file $cache_time
        mkdir -p (dirname $cache_file)
        aeza os json 2>/dev/null | jq -r '.[] | "\(.id)\t\(.name)"' > $cache_file 2>/dev/null || echo "" > $cache_file
    end

    cat $cache_file 2>/dev/null || echo ""
end


function __aeza_create_check_products
    set -l cmd (commandline -poc)
    set -l subcmd_pos (contains -i -- "create" $cmd)
    test (count $cmd) -eq $subcmd_pos
end

function __aeza_create_check_os
    set -l cmd (commandline -poc)
    set -l subcmd_pos (contains -i -- "create" $cmd)
    test (count $cmd) -eq (math $subcmd_pos + 1)
end

complete -c aeza -f -n "__fish_seen_subcommand_from reboot delete rename start stop ssh ip wait" -a "(__aeza_get_servers)"
complete -c aeza -f -n "__fish_seen_subcommand_from create; and __aeza_create_check_products" -a "(__aeza_get_products)"
complete -c aeza -f -n "__fish_seen_subcommand_from create; and __aeza_create_check_os" -a "(__aeza_get_os)"