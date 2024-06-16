require("tasks")
_G.inicialoption = {
    [1] = {
        name = "Task Management",
        task = "manage",
        type = "tasks"
    },
    [2] = {
        name = "Category Managementa",
        task = "manage",
        type = "category"
    },
    [3] = {
        name = "Exit",
        task = "exit"
    }
}

function PrintOptions(options)
    local options = type(options) == "string" and _G[options] or options
    print("\n")
    for k, v in ipairs(options) do
        print(k .. ". " .. v.name)
    end
    print("Please, select an option:")
end

function GetOption(options)
    local number = tonumber(io.read())
    if number and options[number] then
        return options[number]
    end
    print("Choose a valid option")
    return GetOption(options)
end

function Inicial_Option(option)
    local options = type(option) == "string" and _G[option] or option
    PrintOptions(options)
    local choice = GetOption(options)
    if choice.task == "exit" then
        print("Exiting...")
        os.exit()
    end
    ExecuteTask(choice)
end

function ExecuteTask(choice)
    local task_name = "Task_" .. choice.task
    local task_func = _G[task_name]
    if task_func then
        task_func(choice.type)
    end
end

function Task_manage(manage_type)
    local tasks = {
        tasks = {
            [1] = {
                name = "Add",
                task = "add_tasks"
            },
            [2] = {
                name = "View",
                task = "view_tasks"
            },
            [3] = {
                name = "Mark as completed",
                task = "delete_tasks"
            }
        },
        category = {
            [1] = {
                name = "Add",
                task = "add_category"
            },
            [2] = {
                name = "View",
                task = "view_category"
            },
            [3] = {
                name = "Remove",
                task = "delete_category"
            }
        }
    }
    local options = tasks[manage_type]
    PrintOptions(options)
    local choice = GetOption(options)
    local before, after = choice.task:match("([^_]+)_([^_]+)")
    ExecuteTask({
        task = before,
        type = after
    })
end
