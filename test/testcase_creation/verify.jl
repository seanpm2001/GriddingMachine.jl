using JSON
using NCDatasets: Dataset, defVar

include("$(@__DIR__)/../../../GriddingMachine.jl/src/borrowed/GriddingMachineData.jl");

println("start");

dir = "$(@__DIR__)/../../../GriddingMachine.jl/json/";

files = ["ind_lat_lon", "ind_lon_lat", "lat_lon_ind", "lon_ind_lat", "lonf_lat_ind", "lon_latf_ind", "lin_scale", "log_scale", "edge"];

folder = "/home/exgu/GriddingMachine.jl/test/nc_files";

correct = reprocess_data!(folder, JSON.parsefile("$(dir)lon_lat_ind.json"););

for f in files
    _json = "$(dir)$(f).json";

    json_dict = JSON.parse(open(_json));
    name_function = eval(Meta.parse(json_dict["INPUT_MAP_SETS"]["FILE_NAME_FUNCTION"]));
    data_scaling_functions = [_dict["SCALING_FUNCTION"] == "" ? nothing :  eval(Meta.parse(_dict["SCALING_FUNCTION"])) for _dict in json_dict["INPUT_VAR_SETS"]];
    std_scaling_functions = if "INPUT_STD_SETS" in keys(json_dict)
        [_dict["SCALING_FUNCTION"] == "" ? nothing : eval(Meta.parse(_dict["SCALING_FUNCTION"])) for _dict in json_dict["INPUT_STD_SETS"]];
    else
        [nothing for _dict in json_dict["INPUT_VAR_SETS"]];
    end;

    result = reprocess_data!(folder, json_dict; file_name_function = name_function, data_scaling_functions = data_scaling_functions, std_scaling_functions = std_scaling_functions);
    if result != []
        println("$(f) pass = $(isapprox(result, correct; atol = 1e-7))");
    end

end

glob = reprocess_data!(folder, JSON.parsefile("$(dir)glob.json"););
partial = reprocess_data!(folder, JSON.parsefile("$(dir)partial.json"););
if partial != []
    println("partial pass = $(isequal(partial, glob))");
end

println("ok")
