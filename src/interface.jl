"""
MOS interface struct. 
""" 
mutable struct Interface
    url::String
    token::String

    @doc """
        Interface(url::String, token::String)

    Create an interface to MOS at the given url and using
    the given token for authentication.
    """
    Interface(url::String, token::String) = new(url, token)

    @doc """
        Interface(url::String)

    Create an interface to MOS at the given url.
    The authentication token is assumed to be available in the
    environment variable `MOS_BACKEND_TOKEN`.
    """
    function Interface(url::String)
        if haskey(ENV, "MOS_BACKEND_TOKEN")
            token = ENV["MOS_BACKEND_TOKEN"]
        else
            token = ""
        end
        return Interface(url, token)
    end

    @doc """
        Interface()

    Create an interface to MOS
    The url is constructed from the environment variables
    `MOS_BACKEND_HOST` and `MOS_BACKEND_HOST`. The authentication token is
    assumed to be available in the environment variable `MOS_BACKEND_TOKEN`.
    """
    function Interface()
        if haskey(ENV, "MOS_BACKEND_HOST") && haskey(ENV, "MOS_BACKEND_PORT")
            host = ENV["MOS_BACKEND_HOST"]
            port = ENV["MOS_BACKEND_PORT"]
            if port == "443"
              protocol = "https"
            else
              protocol = "http"
            end
            url = "$protocol://$host:$port/api/"
        else
            url = "https://mos.fuinn.ie:443/api/"
        end
        return Interface(url)
    end

end

"""
    new_model(i::Interface, filepath::AbstractString)::Model

Create new MOS model from local annotated file.
"""
function new_model(i::Interface, filepath::AbstractString)::Model
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

"""
    delete_model_with_name(i::Interface, name::String)

Delete model with given name.
"""
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

"""
    get_model(i::Interface, id::Integer)::Model

Get model with given id.
"""
function get_model(i::Interface, id::Integer)::Model
    url = join([i.url, "model/$id/"])
    h = Dict()
    r = HTTP.get(url, add_auth!(h, i.token))
    if r.status != 200
        error("unable to get model")
    end
    return Model(i, JSON.parse(String(r.body)))
end

"""
    get_model_with_name(i::Interface, name::String)::Model

Get model with given name.
"""
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
        m = Model(i, models[1])
        id = m.data["id"]
        return get_model(i, id)
    end
end
