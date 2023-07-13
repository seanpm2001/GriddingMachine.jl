const ATTR_LAT   = Dict("description" => "Latitude", "unit" => "°");
const ATTR_LON   = Dict("description" => "Longitude", "unit" => "°");
const ATTR_CYC   = Dict("description" => "Cycle index", "unit" => "-");
const ATTR_ABOUT = Dict("about" => "This is a file generated using Netcdf module of EmeraldIO.jl",
                        "notes" => "EmeraldIO.jl uses NCDatasets.jl to read and write NC files");

using NCDatasets: Dataset, defVar
using ArchGDAL: read, nraster, getband, getname
using DataFrames

include("netcdf/info.jl");
include("netcdf/read.jl");
include("netcdf/save.jl");
include("netcdf/grow.jl");
include("geotiff/read.jl");
include("Terminal.jl");
