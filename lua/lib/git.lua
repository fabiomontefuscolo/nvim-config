local Git = {}

function Git.get_remote_components()
    -- Get the git remote URL (assuming origin)
    local handle = io.popen("git config --get remote.origin.url 2>/dev/null")
    if not handle then
        return nil
    end

    local remote_url = handle:read("*a"):gsub("%s+$", "")
    handle:close()

    if remote_url == "" then
        return nil
    end

    local hostname, port, path

    -- Parse SSH URL format: git@hostname:path.git or git@hostname:port/path.git
    if remote_url:match("^git@") then
        hostname = remote_url:match("git@([^:]+)")

        local port_path = remote_url:match("git@[^:]+:(.+)")
        if port_path then
            -- Check if port is specified
            port = port_path:match("^(%d+)/")
            if port then
                path = port_path:match("^%d+/(.+)")
            else
                path = port_path
            end
        end
        -- Parse HTTPS URL format: https://hostname:port/path.git or https://hostname/path.git
    elseif remote_url:match("^https?://") then
        hostname = remote_url:match("https?://([^:/]+)")
        port = remote_url:match("https?://[^:/]+:(%d+)")

        if port then
            path = remote_url:match("https?://[^:/]+:%d+/(.+)")
        else
            path = remote_url:match("https?://[^:/]+/(.+)")
        end
    end

    -- Remove .git suffix from path if present
    if path and path:match("%.git$") then
        path = path:gsub("%.git$", "")
    end

    return {
        hostname = hostname,
        port = port,
        path = path,
        full_url = remote_url
    }
end

function Git.get_commit_hash()
    -- Get the current file path relative to the git repository
    local rel_path = vim.fn.expand("%:p")

    -- Execute git command to get the short hash of the latest commit that modified this file
    local cmd = string.format("git log -n 1 --pretty=format:%%h -- %s 2>/dev/null", vim.fn.shellescape(rel_path))
    local handle = io.popen(cmd)

    if not handle then
        return nil
    end

    local commit_hash = handle:read("*a"):gsub("%s+$", "")
    handle:close()

    if commit_hash == "" then
        return nil
    end

    return commit_hash
end

return Git
