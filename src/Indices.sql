1. 

create index v_index on video(numCamara) using hash;
create index i_index on vigia(moradaLocal) using hash;

2.

create index b_index on eventoEmergencia(numtelefone, instantechamada) using hash;

#Not sure about this, vou confirmar com pessoas e perceber porque e que o hash e o melhor aqui