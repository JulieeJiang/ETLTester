require '../../lib/etltester'

config = { 	type: 'sql_server',
			host: 'g9w0118.americas.hpqcorp.net',
			port: '2048', 
			username: 'qmconvrpt', 
			password: 'cnvrgd_01118_dwh'	
		}

sql_txt = %Q{
	SELECT TOP 10 [MappingObjectID]
      ,[MappingSchemaID]
      ,[SourceFieldName]
      ,[SourceValue]
      ,[ConditionExpression]
      ,[ObjectType]
      ,[TargetTableName]
      ,[TargetColumnName]
      ,[StandardValue]
      ,[CreateBy]
      ,[CreateDate]
      ,[UpdateBy]
      ,[UpdateDate]
      ,[CurrentStatus]
  FROM [cnvrgd_dwh_d].[az].[MappingObject]
}



# ret = ETLTester::Util::DBConnection::get_data_from_db config, sql_txt
# ret.each {|col| puts col.join('-')}

config = { 	type: 'sql_server',
			host: 'g9w0118.americas.hpqcorp.net',
			port: '2048', 
			username: 'qmconvrpt', 
			password: 'cnvrgd_01118_dwh'	
		}

sql_txt = %Q{
	SELECT TOP 10 [MappingObjectID]
      ,[MappingSchemaID]
      ,[SourceFieldName]
      ,[SourceValue]
      ,[ConditionExpression]
      ,[ObjectType]
      ,[TargetTableName]
      ,[TargetColumnName]
      ,[StandardValue]
      ,[CreateBy]
      ,[CreateDate]
      ,[UpdateBy]
      ,[UpdateDate]
      ,[CurrentStatus]
  FROM [cnvrgd_dwh_d].[az].[MappingObject]
}

ETLTester::Util::DBConnection::get_transformed_data(config, sql_txt) {|record| puts record.join('-')}