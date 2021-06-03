# Model

```@docs
Model
delete_results(m::Model)
get_id(m::Model)
get_owner_id(m::Model)
get_system(m::Model)
get_name(m::Model)
get_description(m::Model)
get_status(m::Model)
reload(m::Model)
MOSInterface.run(m::Model, blocking::Bool=true, poll_time::Number=1)
set_interface_file(m::Model, name::AbstractString, filepath::AbstractString)
set_interface_object(m::Model, name::AbstractString, data::Any)
show_components(m::Model)
show_recipe(m::Model)
```