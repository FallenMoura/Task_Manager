local json = require("json")

local function Task_getinput(input_type, prompt, table)
    io.write(prompt .. " ")
    io.flush()
    if input_type == 'string' then
        local input = io.read():gsub("^%s*(.-)%s*$", "%1")
        return input ~= "" and input or Task_getinput('string', "You must enter some information:")
    elseif input_type == 'number' then
        local input = tonumber(io.read("*l"))
        return input ~= nil and input or Task_getinput('number', "You must enter a number:")
    elseif input_type == 'date' then
        local function isDateAfterToday(input)
            local day, month, year = input:match("^(%d%d)/(%d%d)/(%d%d%d%d)$")
            local current = os.time({
                year = os.date("*t").year,
                month = os.date("*t").month,
                day = os.date("*t").day
            })
            local input_date = os.time({
                year = tonumber(year),
                month = tonumber(month),
                day = tonumber(day)
            })
            if not input_date then
                return Task_getinput('date',
                    "Invalid date format or date is not after today. Please enter in DD/MM/YYYY format:")
            end
            return input_date > current
        end
        local input = io.read("*l"):gsub("^%s*(.-)%s*$", "%1")
        if input:match("^%d%d/%d%d/%d%d%d%d$") and isDateAfterToday(input) then
            return input
        else
            return Task_getinput('date',
                "Invalid date format or date is not after today. Please enter in DD/MM/YYYY format:")
        end
    end
end

function Task_add(process_type)

    local process_data = {
        id = 0,
        title = nil,
        description = nil,
        validity = nil,
        category = nil,
        category_table = {},
        new_json = {}
    }

    process_data.title = Task_getinput('string', '\nEnter the title:')

    if process_type == 'tasks' then

        process_data.description = Task_getinput('string', '\nEnter a description for the task:')

        process_data.validity = Task_getinput('date', '\nEnter a due date for the task:')
        local function checkcategory()
            print('\nChoose a category for your task\n')
            process_data.category_table = Task_read('category')
            Task_print(process_data.category_table)
            process_data.category = Task_getinput('number', '\nEnter the category number:')
        end
        checkcategory()

        if not Task_print(process_data.category_table, 1, process_data.category, "category") then
            checkcategory()
        end
    end

    print('\nPlease verify the following information:\n')
    Task_print({process_data}, 1, 0, process_type, 'yes')
    print('\nIs it correct? (yes/no)')

    local confirmation = Task_confirmation()

    if confirmation == "yes" then
        if process_type == 'tasks' then
            process_data.new_json = {
                id = 0,
                title = process_data.title,
                description = process_data.description,
                validity = process_data.validity,
                category = process_data.category_table[process_data.category].title
            }
        elseif process_type == 'category' then
            process_data.new_json = {
                id = 0,
                title = process_data.title
            }
        end
        Task_save(process_data.new_json, process_type)
    else
        Task_add()
    end
end

function Task_view(process_type)
    local table_read = Task_read(process_type)
    if process_type == 'tasks' then
        local category_table_read = Task_read('category')
        Task_print(category_table_read)
        local view_id = Task_getinput('number', '\nEnter the category number to view tasks (ALL - 0):')
        local tasks_with_category = {}
        if view_id == 0 then
            tasks_with_category = table_read
        else
            for k, v in ipairs(table_read) do
                if v.category == category_table_read[view_id].title then
                    table.insert(tasks_with_category, v)
                end
            end
        end
        table_read = tasks_with_category
    end
    Task_print(table_read)
    local view_id = Task_getinput('number', '\nEnter the number you want to view:')
    if not Task_print(table_read, 1, view_id, process_type, 'yes') then
        Task_view(process_type)
    end
    Inicial_Option("inicialoption")
end

function Task_save(new_json, file_type)
    local table_read = Task_read(file_type)

    local max_id = 0
    for _, v in ipairs(table_read) do
        max_id = math.max(max_id, v.id)

    end
    new_json.id = max_id + 1

    table.insert(table_read, new_json)
    Task_Write(file_type, table_read)

    Inicial_Option("inicialoption")
end

function Task_delete(file_type)
    local table_read = Task_read(file_type)
    Task_print(table_read)

    local task_id = Task_getinput('number', '\nEnter the number to delete:')
    if not Task_print(table_read, 1, task_id, file_type, 'yes') then
        Task_delete(file_type)
    else
        print('\nIs it correct? (yes/no)')
        local confirmation = Task_confirmation()

        if confirmation == "yes" then
            for k, v in ipairs(table_read) do
                if v.id == task_id then
                    table.remove(table_read, k)
                    break
                end
            end
            for i, task in ipairs(table_read) do
                task.id = i
            end
            Task_Write(file_type, table_read)
        end
        Inicial_Option("inicialoption")
    end
end

function Task_read(file_type)
    local file = io.open("../json/" .. file_type .. ".json", "r")
    if file then
        local content = file:read("*a")
        file_type = json.decode(content)
        file:close()
    end
    return file_type or {}
end

function Task_confirmation()
    local confirmation = io.read("*l"):lower():gsub("%s+", "")
    while confirmation ~= "yes" and confirmation ~= "no" do
        print("Please enter 'yes' or 'no'")
        confirmation = io.read("*l"):lower():gsub("%s+", "")
    end
    return confirmation
end

function Task_print(table, number, task_id, file_type, ifprint)
    local found = false
    if next(table) == nil then
        print('You must create something first!!\n')
        Inicial_Option("inicialoption")
    else
        if number == 1 then
            for _, v in ipairs(table) do
                if v.id == task_id then
                    found = true
                    if ifprint == 'yes' then
                        if file_type == 'tasks' then
                            print("Title: " .. v.title .. "\nDescription: " .. v.description .. "\nDue Date: " ..
                                      v.validity .. "\nCategory: " .. v.category .. "\n")
                        elseif file_type == 'category' then
                            print("Title: " .. v.title .. "\n\n")
                        end
                    end
                    break
                end
            end
            if not found then
                print('\nNo match found for this number')
                return false
            end
            return true
        else
            for _, v in ipairs(table) do
                print("[" .. v.id .. "] " .. "- " .. v.title)
            end
        end
    end
end

function Task_Write(file_type, table_read)
    local file = io.open("../json/" .. file_type .. ".json", "w")

    if file then
        file:write(json.encode(table_read))
        file:close()
        print("Task successfully saved to " .. file_type .. ".json.\n")
    end
end
