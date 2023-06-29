/**
* Name: Simulator
* Author: Lê Đức Toàn
*/


model Simulator


import './food-disease-config.gaml'
import './water-disease-config.gaml'
import './food-water-disease-pig.gaml'


global {
	file pigs;
	
    init {
    	pigs <- csv_file("../includes/input/multi-disease-pigs.csv", true);
    	create FoodWaterDiseasePig from: pigs;
    	FoodWaterDiseasePig[0].id <- 0;
        create Trough number: 5;
        loop i from: 0 to: 4 {
        	Trough[i].location <- trough_locs[i];
        }
        create FoodDiseaseConfig number: 1;
        create WaterDiseaseConfig number: 1;
        FoodDiseaseConfig[0].day <- 10;
        WaterDiseaseConfig[0].day <- 11;
    }
    
    reflex stop when: cycle = 60 * 24 * 55 {
    	do pause;
    }
}

experiment Multi {
    output {
        display Simulator {
            grid Background lines: #black;
            species FoodWaterDiseasePig aspect: base;
        }
        display CFI refresh: every((60 * 24)#cycles) {
        	chart "CFI" type: series {
        		loop pig over: FoodWaterDiseasePig {
        			data string(pig.id) value: pig.cfi;
        		}
        	}
        }
        display Weight refresh: every((60 * 24)#cycles) {
        	chart "Weight" type: histogram {
        		loop pig over: FoodWaterDiseasePig {
        			data string(pig.id) value: pig.weight;
        		}
        	}
        }
        display CFIPig0 refresh: every((60 * 24)#cycles) {
        	chart "CFI vs Target CFI" type: series {
        		data 'CFI' value: FoodWaterDiseasePig[0].cfi;
        		data 'Target CFI' value: FoodWaterDiseasePig[0].target_cfi;
        	}
        }
        display DFIPig0 refresh: every((60 * 24)#cycles) {
        	chart "DFI vs Target DFI" type: series {
        		data 'DFI' value: FoodWaterDiseasePig[0].dfi;
        		data 'Target DFI' value: FoodWaterDiseasePig[0].target_dfi;
        	}
        }
    }
    
    reflex log when: mod(cycle, 24 * 60) = 0 {
    	ask simulations {
    		loop pig over: FoodWaterDiseasePig {
    			save [
    				floor(cycle / (24 * 60)),
    				pig.id,
    				pig.target_dfi,
    				pig.dfi,
    				pig.target_cfi,
    				pig.cfi,
    				pig.weight,
    				pig.eat_count,
    				pig.excrete_each_day,
    				pig.excrete_count,
    				pig.expose_count_per_day,
    				pig.recover_count
    			] to: "../includes/output/multi/" + string(pig.id) + ".csv" rewrite: false type: "csv";	
    		}
		}		
    }
}