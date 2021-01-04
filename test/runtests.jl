using GriddingMachine
using Test

FT = Float32;




# test utility functions
@testset "GriddingMachine --- Lat/Lon indicies" begin
    println("");
    # test the lat_ind and lon_ind
    @test typeof(lat_ind(  0.0)) == Int           ;
    @test typeof(lat_ind( 91.0)) == ErrorException;
    @test typeof(lon_ind(  0.0)) == Int           ;
    @test typeof(lon_ind(350.0)) == Int           ;
    @test typeof(lon_ind(361.0)) == ErrorException;
end




# test clumping factor artifacts
@testset "GriddingMachine --- Load and Read datasets" begin
    println("Downloading the artifacts, please wait...");
    predownload_artifact.(["GPP_MPI_v006_1X_8D", "GPP_VPM_v20_1X_8D",
                           "NPP_MODIS_1X_1Y", "canopy_height_20X_1Y",
                           "clumping_index_12X_1Y", "clumping_index_2X_1Y_PFT",
                           "land_mask_ERA5_4X_1Y", "leaf_area_index_4X_1M",
                           "leaf_chlorophyll_2X_7D", "leaf_traits_2X_1Y",
                           "river_maps_4X_1Y", "surface_data_2X_1Y",
                           "tree_density_12X_1Y"]);

    println("");
    CHT_LUT = load_LUT(CanopyHeightGLAS{FT}());                @test true;
    CLI_PFT = load_LUT(ClumpingIndexPFT{FT}());                @test true;
    CLI_LUT = load_LUT(ClumpingIndexMODIS{FT}(), "12X", "1Y"); @test true;
    CHT_LUT = load_LUT(FloodPlainHeight{FT}());                @test true;
    MPI_LUT = load_LUT(GPPMPIv006{FT}(), 2005, "1X", "8D");    @test true;
    VPM_LUT = load_LUT(GPPVPMv20{FT}() , 2005, "1X", "8D");    @test true;
    LAI_LUT = load_LUT(LAIMonthlyMean{FT}());                  @test true;
    CHT_LUT = load_LUT(LandElevation{FT}());                   @test true;
    LMK_LUT = load_LUT(LandMaskERA5{FT}());                    @test true;
    CHL_LUT = load_LUT(LeafChlorophyll{FT}());                 @test true;
    LNC_LUT = load_LUT(LeafNitrogen{FT}());                    @test true;
    LPC_LUT = load_LUT(LeafPhosphorus{FT}());                  @test true;
    SLA_LUT = load_LUT(LeafSLA{FT}());                         @test true;
    NPP_LUT = load_LUT(NPPModis{FT}());                        @test true;
    SLA_LUT = load_LUT(RiverHeight{FT}());                     @test true;
    SLA_LUT = load_LUT(RiverLength{FT}());                     @test true;
    SLA_LUT = load_LUT(RiverManning{FT}());                    @test true;
    SLA_LUT = load_LUT(RiverWidth{FT}());                      @test true;
    TDT_LUT = load_LUT(TreeDensity{FT}(), "12X", "1Y");        @test true;
    SLA_LUT = load_LUT(UnitCatchmentArea{FT}());               @test true;
    VCM_LUT = load_LUT(VcmaxOptimalCiCa{FT}());                @test true;

    if Sys.islinux()
        println("Downloading the artifacts, please wait...");
        predownload_artifact.(["GPP_MPI_v006_2X_1M", "GPP_MPI_v006_2X_8D",
                               "GPP_VPM_v20_5X_8D"]);
        MPI_LUT = load_LUT(GPPMPIv006{FT}(), 2005, "2X", "1M"); @test true;
        MPI_LUT = load_LUT(GPPMPIv006{FT}(), 2005, "2X", "8D"); @test true;
        VPM_LUT = load_LUT(GPPVPMv20{FT}() , 2005, "5X", "8D"); @test true;
    end

    read_LUT(CLI_PFT, FT(30), FT(115), 2); @test true;
    read_LUT(SLA_LUT, FT(30), FT(115)   ); @test true;
    read_LUT(CLI_PFT, (FT(30),FT(40)), (FT(80),FT(115)), (1,5)); @test true;
    read_LUT(SLA_LUT, (FT(30),FT(40)), (FT(80),FT(115))       ); @test true;

    view_LUT(CLI_PFT, FT(30), FT(115), 2); @test true;
    view_LUT(SLA_LUT, FT(30), FT(115)   ); @test true;
    view_LUT(CLI_PFT, (FT(30),FT(40)), (FT(80),FT(115)), (1,5)); @test true;
    view_LUT(SLA_LUT, (FT(30),FT(40)), (FT(80),FT(115))       ); @test true;

    # only for high memory and storage cases, e.g., server
    if Sys.islinux() && (Sys.free_memory() / 2^30) > 100
        println("Downloading the artifacts, please wait...");
        predownload_artifact.(["clumping_index_240X_1Y", "GPP_VPM_v20_12X_8D",
                               "tree_density_120X_1Y"]);
        CLI_LUT = load_LUT(ClumpingIndexMODIS{FT}(), "240X", "1Y"); @test true;
        VPM_LUT = load_LUT(GPPVPMv20{FT}() , 2005, "12X", "8D");    @test true;
        TDT_LUT = load_LUT(TreeDensity{FT}(), "120X", "1Y");        @test true;
    end
end




# test clumping factor artifacts
@testset "GriddingMachine --- Mask dataset" begin
    println("");
    CHT_LUT = load_LUT(CanopyHeightGLAS{FT}());
    SLA_LUT = load_LUT(LeafSLA{FT}());
    mask_LUT!(CHT_LUT, [0,Inf]); @test true;
    mask_LUT!(CHT_LUT, -9999  ); @test true;
    mask_LUT!(SLA_LUT, [0,Inf]); @test true;
    mask_LUT!(SLA_LUT, -9999  ); @test true;
end




# test clumping factor artifacts
@testset "GriddingMachine --- Regrid and Save dataset" begin
    println("");
    CHT_LUT = load_LUT(CanopyHeightGLAS{FT}());
    mask_LUT!(CHT_LUT, [0,10]);
    REG_LUT = regrid_LUT(CHT_LUT, 2; nan_weight=true ); @test true;
    REG_LUT = regrid_LUT(CHT_LUT, 2; nan_weight=false); @test true;
    save_LUT(REG_LUT, "test.nc"); @test true;
    rm("test.nc");
end