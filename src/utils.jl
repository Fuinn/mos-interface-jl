import HTTP
import JSON

function correct_url(url::AbstractString, base_url::AbstractString)::String
    base_uri = HTTP.URI(base_url)
    uri = HTTP.URI(url)
    new_uri = HTTP.URI(scheme=uri.scheme,
                       userinfo=uri.userinfo,
                       host=uri.host,
                       port=base_uri.port,
                       path=uri.path,
                       query=uri.query,
                       fragment=uri.fragment)
    return "$new_uri"
end

function add_auth!(h::Dict{<:Any, <:Any}, token::String)::Dict{Any, Any}
    if (!isempty(token))
        push!(h, "Authorization" => string("Token ", token))
    end
    return h
end
