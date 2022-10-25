cd Buildbox && docker build --ssh default -t dbarrow257/buildbox:latest . && cd ..
cd Root_6.24.06 && docker build --ssh default -t dbarrow257/root_6.24.06:latest . && cd ..
cd GENIE_3.0.6 && docker build --ssh default -t dbarrow257/genie_3.0.6:latest . && cd ..
cd NEUT_5.5.0 && docker build --ssh default -t dbarrow257/neut_5.5.0:latest . && cd ..
cd NuWro_21.09 && docker build --ssh default -t dbarrow257/nuwro_21.09:latest . && cd ..
cd GiBUU_21Release && docker build --ssh default -t dbarrow257/gibuu_21:latest . && cd ..
cd Nuisance && docker build --ssh default -t dbarrow257/nuisance:latest . && cd ..

