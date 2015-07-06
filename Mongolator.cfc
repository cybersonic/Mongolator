component{

	function init(db, struct dbauth={}){
		variables.db = db;
		
		variables.dbauth = dbauth;
	}

	function setBeanFactory(beanFactory){
		variables.bf = beanFactory;
	}

	public Any function find(String collection, Any Bean="", Struct findquery={}, Struct projection={}, Numeric limit=0, Struct sort={}, boolean raw = false){
		var col = checkAndCreate(collection);
		var retRaw = col.find(findquery, projection);
		if(limit GT 0){
			retRaw.limit(limit);
		}
		if(!sort.isEmpty()){
			retRaw.sort(sort);
		}

		if(raw){
			return retRaw;
		}
		return CursorToArray(Bean, retRaw)
		
	}

	public Any function findOne(String collection, Any Bean="", Struct findquery={}, Struct projection={}){
		var col = checkAndCreate(collection);
		var retRaw = col.findOne(findquery, projection);
		
		//if we didn't find anything, retRaw will be null

		if(isNull(retRaw)){
			return;
		}

		if(Len(Bean)){
			return bf.fillProperties(Bean, retRaw);	
		}
		else {
			return retRaw;
		}
		
	}


	//Simple update
	public void function update(String collection, Struct filter, Struct properties ){

		var col = checkAndCreate(collection);


		col.update(filter, {'$set': properties});
	}



	public void function save(String collection, Any id, Struct document){
		var col = checkAndCreate(collection);
		document["_id"] = id; //set the id
		var retRaw = col.save(document);
	}

	public void function bulkInsert(String collection, Array documents){
		var col = checkAndCreate(collection);
		col.insert(documents);
	}

	private function checkAndCreate(String collection){
	
		if(!structIsEmpty(variables.dbauth)){
			db.auth(dbauth.username, dbauth.password);
		}
		
		if(!db.collectionExists(collection)){
			db[collection] = {}
		}
		
		return db[collection];
	}

	private Array function CursorToArray(Bean, Cursor){
		var ret = [];
		for(var item in Cursor){

			if(Len(Bean)){
				ret.append(bf.fillProperties(Bean, item));	
			}
			else{
				ret.append(item);
			}
			
		}
		return ret;
	}



}
