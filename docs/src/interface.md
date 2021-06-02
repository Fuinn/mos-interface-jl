# Interface

```@meta
CurrentModule = MOSInterface
```

```@docs
Interface
Interface()
Interface(url::String)
Interface(url::String, token::String)
new_model(i::Interface, filepath::AbstractString)
delete_model_with_name(i::Interface, name::String)
get_model(i::Interface, id::Integer)
get_model_with_name(i::Interface, name::String)
```