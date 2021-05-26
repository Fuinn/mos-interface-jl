mutable struct Interface
    url::String
    token::String

    Interface(url::String, token::String) = new(url, token)

    function Interface(url::String)
        if haskey(ENV, "MOS_BACKEND_TOKEN")
            token = ENV["MOS_BACKEND_TOKEN"]
        else
            token = ""
        end
        return Interface(url, token)
    end

    function Interface()
        host = ENV["MOS_BACKEND_HOST"]
        port = ENV["MOS_BACKEND_PORT"]
        url = "http://$host:$port/api/"
        return Interface(url)
    end

end

function new_model(i::Interface, filepath::AbstractString)
    url = join([i.url, "model/create_from_file/"])
    open(filepath, "r") do source_file
        f = HTTP.Form(Dict("source_file" => source_file))
        h = Dict("Content-Type" => "multipart/form-data; boundary=$(f.boundary)")
        r = HTTP.post(url, add_auth!(h, i.token), body=f)
        if r.status != 200
            error("unable to create model")
        end
        return Model(i, JSON.parse(String(r.body)))
    end
end 

function delete_model_with_name(i::Interface, name::String)
    url = join([i.url, "model/"])
    h = Dict()
    r = HTTP.get(url, add_auth!(h, i.token), query=["name" => name])
    if r.status != 200
        error("unable to get model")
    end
    models = JSON.parse(String(r.body))
    for m in models
        model = Model(i, m)
        id = get_id(model)
        url = join([i.url, "model/$id/"])
        h = Dict()
        r = HTTP.delete(url, add_auth!(h, i.token))
        if r.status != 204
            error("unable to delete model")
        end
    end
end

function get_model(i::Interface, id::Integer)::Model
    url = join([i.url, "model/$id/"])
    h = Dict()
    r = HTTP.get(url, add_auth!(h, i.token))
    if r.status != 200
        error("unable to get model")
    end
    return Model(i, JSON.parse(String(r.body)))
end

function get_model_with_name(i::Interface, name::String)::Model
    url = join([i.url, "model/"])
    h = Dict()
    r = HTTP.get(url, add_auth!(h, i.token), query=["name" => name])
    if r.status != 200
        error("unable to get model")
    end
    models = JSON.parse(String(r.body))
    if isempty(models)
        error("No model found with name $name")
    elseif length(models) > 1
        error("More than one model found with name $name")
    else
        return Model(i, models[1])
    end
end