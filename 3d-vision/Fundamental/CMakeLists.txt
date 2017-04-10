cmake_minimum_required(VERSION 2.6)
file(TO_CMAKE_PATH "$ENV{IMAGINEPP_ROOT}/CMake" p)
list(APPEND CMAKE_MODULE_PATH "${p}") #For old Imagine++
list(APPEND CMAKE_SYSTEM_FRAMEWORK_PATH /Library/Frameworks) #Mac, why not auto?
find_package(Imagine REQUIRED)

project(Fundamental)
add_executable(Fundamental
        Fundamental.cpp
        Imagine/SIFT_VL.cpp
        Imagine/vl/generic.c Imagine/vl/host.c Imagine/vl/imop.c Imagine/vl/sift.c)
ImagineUseModules(Fundamental LinAlg Images)
