1. 

create index v_index on video(numCamara) using hash;
create index i_index on vigia(moradaLocal) using hash;

2.

create index v_index on eventoEmergencia(numtelefone, instantechamada) using hash;

#Isto nao esta certo mas ainda nao sei como fazer com 2 tabelas diferentes, se devo fazer com 2 indices ou nao. Vou perguntar a pessoas