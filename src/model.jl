"""
MOS model struct.
"""
mutable struct Model
    interface::Interface
    data::Dict{String, <:Any}
end

function __add_variable_states__(m::Model, var_states::Array{<:Any, 1})
    url = join([m.interface.url, "variable-state/bulk_create/"])
    json_data = JSON.json(var_states)
    h = Dict("Content-Type" => "application/json")
    r = HTTP.post(url, add_auth!(h, m.interface.token), body=json_data)
    if r.status != 201
        error("unable to add variable states")
    end
end

function __add_function_states__(m::Model, func_states::Array{<:Any, 1})
    url = join([m.interface.url, "function-state/bulk_create/"])
    json_data = JSON.json(func_states)
    h = Dict("Content-Type" => "application/json")
    r = HTTP.post(url, add_auth!(h, m.interface.token), body=json_data)
    if r.status != 201
        error("unable to add function states")
    end
end


function __add_constraint_states__(m::Model, constr_states::Array{<:Any, 1})
    url = join([m.interface.url, "constraint-state/bulk_create/"])
    json_data = JSON.json(constr_states)
    h = Dict("Content-Type" => "application/json")
    r = HTTP.post(url, add_auth!(h, m.interface.token),  body=json_data)
    if r.status != 201
        error("unable to add constraint states")
    end
end

function __add_problem_state__(m::Model, p_state::Dict)
    url = join([m.interface.url, "problem-state/"])
    json_data = JSON.json(p_state)
    h = Dict("Content-Type" => "application/json")
    r = HTTP.post(url, add_auth!(h, m.interface.token),  body=json_data)
    if r.status != 201
        error("unable to add problem state")
    end
end

function __add_solver_state__(m::Model, s_state::Dict)
    url = join([m.interface.url, "solver-state/"])
    json_data = JSON.json(s_state)
    h = Dict("Content-Type" => "application/json")
    r = HTTP.post(url, add_auth!(h, m.interface.token), body=json_data)
    if r.status != 201
        error("unable to add solver state")
    end
end

function __delete_input_files__(m::Model)
    for f in __get_interface_files__(m, "input")
        filename = string(f["name"], f["extension"])
        if isfile(filename)
            println("Deleting file $filename")
            rm(filename)
        end
    end
end

function __delete_input_object_files__(m::Model)
    for f in __get_interface_objects__(m, "input")
        filename = string(f["name"], ".json")
        if isfile(filename)
            println("Deleting file $filename")
            rm(filename)
        end
    end
end

function __delete_output_files__(m::Model)
    for f in __get_interface_files__(m, "output")
        filename = string(f["name"], f["extension"])
        if isfile(filename)
            println("Deleting file $filename")
            rm(filename)
        end
    end
end

function __download_input_files__(m::Model)
    for f in __get_interface_files__(m, "input")
        name = f["name"]
        ext = f["extension"]
        filename = "$name$ext"
        println("Downloading file $filename")
        url = join([f["url"], "url/"])
        r = HTTP.get(correct_url(url, m.interface.url), 
                     add_auth!(Dict(), m.interface.token))
        if r.status != 200
            error("unable to download files")
        end
        file_url = correct_url(JSON.parse(String(r.body)), m.interface.url)
        HTTP.open("GET", file_url, add_auth!(Dict(), m.interface.token)) do stream
            Base.open(filename, "w") do fh
                while(!eof(stream))
                    write(fh, readavailable(stream))
                end
            end
        end
    end
end

function __download_input_object_files__(m::Model)
    for f in __get_interface_objects__(m, "input")
        name = f["name"]
        ext = ".json"
        filename = "$name$ext"
        println("Downloading file $filename")
        url = correct_url(f["data"], m.interface.url)
        r = HTTP.get(url, add_auth!(Dict(), m.interface.token))
        if r.status != 200
            error("unable to download files")
        end
        Base.open(filename, "w") do fh
            write(fh, String(r.body))
        end
    end
end


function __get_solver__(m::Model)
    return m.data["solver"]
end

function __get_problem__(m::Model)
    return m.data["problem"]
end

function __get_variables__(m::Model)
    return m.data["variables"]
end

function __get_functions__(m::Model)
    return m.data["functions"]
end

function __get_constraints__(m::Model)
    return m.data["constraints"]
end

function __get_helper_objects__(m::Model)
    return m.data["helper_objects"]
end

function __get_interface_objects__(m::Model, type::Any=nothing)
    return [o for o in m.data["interface_objects"] if type === nothing || o["type"] == type]
end

function __get_interface_files__(m::Model, type::Any=nothing)
    return [f for f in m.data["interface_files"] if type === nothing || f["type"] == type]
end

function __set_status__(m::Model, status::AbstractString)
    url = join([m.data["url"], "set_status/"])
    h = Dict("Content-Type" => "application/json")
    r = HTTP.put(correct_url(url, m.interface.url), 
                 add_auth!(h, m.interface.token),  
                 body=JSON.json(status))
    if r.status != 200
        error("unable to set model status")
    end
    m.data["status"] = status
end

function __set_var_type_and_shape__(m::Model, 
                                    v::Dict{<:AbstractString, <:Any}, 
                                    type::AbstractString, 
                                    shape::Union{Array{Int64, 1}, Nothing})
    @assert(type in ["scalar", "array", "hashmap"])
    v["type"] = type
    v["shape"] = shape
    json_v = JSON.json(v)
    url = correct_url(v["url"], m.interface.url)
    h = Dict("Content-Type" => "application/json")
    r = HTTP.put(url, add_auth!(h, m.interface.token),  body=json_v)
    if r.status != 200
        error("unable to set variable type and size")
    end
end

function __set_function_type_and_shape__(m::Model, 
                                         f::Dict{<:AbstractString, <:Any}, 
                                         type::AbstractString, 
                                         shape::Union{Array{Int64, 1}, Nothing})
    @assert(type in ["scalar", "array", "hashmap"])
    f["type"] = type
    f["shape"] = shape
    json_f = JSON.json(f)
    url = correct_url(f["url"], m.interface.url)
    h = Dict("Content-Type" => "application/json")
    r = HTTP.put(url, add_auth!(h, m.interface.token),  body=json_f)
    if r.status != 200
        error("unable to set function type and size")
    end
end

function __set_constraint_type_and_shape__(m::Model, 
                                           c::Dict{<:AbstractString, <:Any}, 
                                           type::AbstractString, 
                                           shape::Union{Array{Int64, 1}, Nothing})
    @assert(type in ["scalar", "array", "hashmap"])
    c["type"] = type
    c["shape"] = shape
    json_c = JSON.json(c)
    url = correct_url(c["url"], m.interface.url)
    h = Dict("Content-Type" => "application/json")
    r = HTTP.put(url, add_auth!(h, m.interface.token),  body=json_c)
    if r.status != 200
        error("unable to set constraint type and size")
    end
end


function __set_interface_file__(m::Model, f::Dict{<:AbstractString, <:Any}, filepath::AbstractString)
    open(filepath, "r") do data_file 
        f["extension"] = splitext(filepath)[end]
        temp = merge(Dict("data_file" => data_file), f)
        temp["data"] = ""
        data = HTTP.Form(temp)
        h = Dict("Content-Type" => "multipart/form-data; boundary=$(data.boundary)")
        url = correct_url(f["url"], m.interface.url)
        r = HTTP.put(url, add_auth!(h, m.interface.token), body=data)
        if r.status != 200
            error("unable to set interface file")
        end
    end
end

function __set_interface_object__(m::Model, o::Dict{<:AbstractString, <:Any}, data::Any)
    json_data = JSON.json(Dict("data" => data))
    url = correct_url(o["url"], m.interface.url)
    h = Dict("Content-Type" => "application/json")
    r = HTTP.put(url, add_auth!(h, m.interface.token),  body=json_data)
    if r.status != 200
        error("unable to set io object")
    end
end

function __set_helper_object__(m::Model, o::Dict{<:AbstractString, <:Any}, data::Any)
    json_data = JSON.json(Dict("data" => data))
    url = correct_url(o["url"], m.interface.url)
    h = Dict("Content-Type" => "application/json")
    r = HTTP.put(url, add_auth!(h, m.interface.token),  body=json_data)
    if r.status != 200
        error("unable to set helper object")
    end
end

function __set_execution_log__(m::Model, log::AbstractString)
    url = join([m.data["url"], "set_execution_log/"])
    url = correct_url(url, m.interface.url)
    h = Dict("Content-Type" => "application/json")
    r = HTTP.put(url, add_auth!(h, m.interface.token), body=JSON.json(log))
    if r.status != 200
        error("unable to set execution log")
    end 
    m.data["execution_log"] = log
end

function __write__(m::Model, f::IO)
    url = join([m.data["url"], "write/"])
    h = Dict()
    r = HTTP.get(correct_url(url, m.interface.url), 
                 add_auth!(h, m.interface.token))
    if r.status != 200
        error("unable to write model")
    end
    recipe = JSON.parse(String(r.body)) 
    write(f, recipe)
end

function delete_results(m::Model)
    url = join([m.data["url"], "delete_results/"])(
    h = Dict())
    r = HTTP.post(correct_url(url, m.interface.url),
                  add_auth!(h, m.interface.token))
    if r.status != 200
        error("error trying to delete results")
    end
end

function set_interface_file(m::Model, name::AbstractString, filepath::AbstractString)
    for f in __get_interface_files__(m)
        if f["name"] == name
            __set_interface_file__(m, f, filepath)
            return 
        end
    end
    error("invalid file name")
end

function set_interface_object(m::Model, name::AbstractString, data::Any)
    for f in __get_interface_objects__(m)
        if f["name"] == name
            __set_interface_object__(m, f, data)
            return 
        end
    end
    error("invalid file name")
end

function run(m::Model, blocking::Bool=true, poll_time::Number=1)
    url = join([m.data["url"], "run/"])
    h = Dict()    
    r = HTTP.post(correct_url(url, m.interface.url), 
                  add_auth!(h, m.interface.token))
    if r.status != 200
        error("error trying to solve model")
    end
    status = get_status(m)
    while status in ("queued", "running") && blocking
        sleep(poll_time)
        status = get_status(m)
    end
    if blocking
        reload(m)
    end
end

function reload(m::Model)
    h = Dict()
    r = HTTP.get(correct_url(m.data["url"], m.interface.url), 
                 add_auth!(h, m.interface.token))
    if r.status != 200
        error("unable to reload model")
    end
    m.data = JSON.parse(String(r.body))
end

function show_components(m::Model)

    title = string("Model: ",m.data["name"])

    println("")
    println(title)
    println("----------------")
    println("")
    println("Input Files:")
    for f in __get_interface_files__(m, "input")
        println(string(f["name"],f["extension"]))
    end
    println("Input Objects:")
    for o in __get_interface_objects__(m, "input")
        println(string(o["name"]))
    end
    println("Helper Objects:")
    for o in __get_helper_objects__(m)
        println(string(o["name"]))
    end
    println("Variables:")
    for v in __get_variables__(m)
        println(string(v["name"]))
    end
    println("Functions:")
    for f in __get_functions__(m)
        println(string(f["name"]))
    end
    println("Constraints:")
    for c in __get_constraints__(m)
        println(string(c["name"]))
    end
    println("Solver:")
    println(string(__get_solver__(m)["name"]))
    println("Problem:")
    println(string(__get_problem__(m)["name"]))
    println("Output Files")
    for f in __get_interface_files__(m, "output")
        println(string(f["name"],f["extension"]))
    end
    println("Output Objects:")
    for o in __get_interface_objects__(m, "output")
        if o["type"] == "output"
            println(string(o["name"]))
        end
    end
end

function show_recipe(m::Model)
    recipe = IOBuffer()
    __write__(m, recipe)
    println(String(take!(recipe)))
end

function get_id(m::Model)
    return m.data["id"]
end

function get_owner_id(m::Model)
    return m.data["owner"]["id"]
end

function get_system(m::Model)
    return m.data["system"]
end

function get_name(m::Model)
    return m.data["name"]
end

function get_description(m::Model)
    return m.data["description"]
end

function get_status(m::Model)

    url = join([m.data["url"], "get_status/"])
    h = Dict()
    r = HTTP.get(correct_url(url, m.interface.url), 
                 add_auth!(h, m.interface.token))
    if r.status != 200
        error("unable to get model status")
    end
    
    status = JSON.parse(String(r.body))
    m.data["status"] = status

    return status
end


            
