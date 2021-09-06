###############################################################################
#
# Load look-up tables
#
###############################################################################
"""
    load_LUT(dt::AbstractDataset{FT},
             g_zoom::Int;
             nan_weight::Bool = false
    ) where {FT<:AbstractFloat}
    load_LUT(dt::AbstractDataset{FT},
             res_g::String,
             res_t::String,
             g_zoom::Int;
             nan_weight::Bool = false
    ) where {FT<:AbstractFloat}
    load_LUT(dt::AbstractDataset{FT},
             year,
             res_g::String,
             res_t::String,
             g_zoom::Int;
             nan_weight::Bool = false
    ) where {FT<:AbstractFloat}
    load_LUT(dt::AbstractDataset{FT}) where {FT<:AbstractFloat}
    load_LUT(dt::AbstractDataset{FT},
             res_g::String,
             res_t::String
    ) where {FT<:AbstractFloat}
    load_LUT(dt::AbstractDataset{FT},
             year::Int,
             res_g::String,
             res_t::String
    ) where {FT<:AbstractFloat}
    load_LUT(dt::AbstractDataset{FT},
             file::String,
             format::AbstractFormat,
             label::String,
             res_t::String,
             rev_lat::Bool,
             var_name::String,
             var_attr::Dict{String,String},
             var_lims::Array{FT,1}
    ) where {FT<:AbstractFloat}

Load look up table and return the struct, given
- `dt` Dataset type, subtype of [`AbstractDataset`](@ref)
- `g_zoom` The spatial resolution factor, e.g., 2 means a 1/2 ° resolution
- `res_g` Resolution in degree
- `res_t` Resolution in time
- `year` Which year
- `file` File name to read, useful to read local files
- `format` Dataset format from [`AbstractFormat`](@ref)
- `label` Variable label in dataset, e.g., var name in .nc files, band numer in
    .tif files
- `rev_lat` Whether latitude is stored reversely in the dataset, e.g., 90 to
    -90. If true, mirror the dataset on latitudinal direction
- `var_name` Variable name of [`GriddedDataset`](@ref)
- `var_attr` Variable attributes of [`GriddedDataset`](@ref)
- `var_lims` Realistic variable ranges
"""
function load_LUT(
            dt::AbstractDataset{FT},
            year,
            res_g::String,
            res_t::String,
            g_zoom::Int;
            nan_weight::Bool = false
) where {FT<:AbstractFloat}
    ds  = load_LUT(dt, year, res_g, res_t);
    rds = regrid_LUT(ds, Int(size(ds.data,1)/360/g_zoom); nan_weight=nan_weight);

    return rds
end




function load_LUT(
            dt::AbstractDataset{FT},
            year::Int,
            res_g::String,
            res_t::String
) where {FT<:AbstractFloat}
    _fn, _fmt, _lab, _res, _rev, _vn, _va, _lmt = query_LUT(dt, year, res_g, res_t);

    return load_LUT(dt, _fn, _fmt, _lab, _res, _rev, _vn, _va, _lmt)
end




function load_LUT(
            dt::AbstractDataset{FT},
            file::String,
            format::FormatNC,
            label::String,
            res_t::String,
            rev_lat::Bool,
            var_name::String,
            var_attr::Dict{String,String},
            var_lims::Array{FT,1}
) where {FT<:AbstractFloat}
    _data = read_nc(FT, file, label);

    # reverse latitude
    if rev_lat
        _data = _data[:,end:-1:1,:];
    end

    # convert data to 3D array
    if length(size(_data)) == 2
        data = cat(_data; dims=3);
    else
        data = _data;
    end

    return GriddedDataset{FT}(data     = data    ,
                              lims     = var_lims,
                              res_time = res_t   ,
                              dt       = dt      ,
                              var_name = var_name,
                              var_attr = var_attr)
end
