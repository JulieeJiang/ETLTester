require 'etltester'
mapping("QUIX_MPP_Mapping") do
    #Using keyword define_variables to define variable checkpointendtime.
    define_variable :checkpointendtime do
        Util::DBConnection.get_data_from_db Uti::Configuration::get_config(:DBConnection,
            'select max(checkpointendtime) from az.MappingSchemaLoadingAudit where MappingSchemaID=860 and CurrentStatus=\'succeed\'')[0][0]
    end

    # declare table will be used in ETL for QUIX MPP Workflow
    # Notes:
    #       1.Please update projects in source SQL if needed
    set_source_connection :oracle_QUIX_connection
    declare_source_table %Q{select * from BO_QX_CR where  submitdate<= to_date(#{variables[:checkpointendtime]},'YYYY-MM-DD HH24:MI:SS') and  BO_QX_CR.PROJECT_HIERARCHY in('Major Program Group-->Manageability-->ESSN IaaSC','Major Program Group-->Manageability-->ESSN Foundation Services','Major Program Group-->Manageability-->Server Provisioning','Major Program Group-->Manageability-->CIC','Major Program Group-->Manageability-->VSE','Major Program Group-->Manageability-->Logical Server Utility','Major Program Group-->Manageability-->VSE docs','Major Program Group-->Manageability-->Workload Mgr','Major Program Group-->HP-UX-->Manageability-->Utilization Provider','Major Program Group-->HP-UX-->Manageability-->Process Resource Mgr','Major Program Group-->HP-UX-->Manageability-->Instant Capacity GUI','Major Program Group-->HP-UX-->Manageability-->Application Discovery','Major Program Group-->HP-UX-->Manageability-->Global Workload Mgr','Major Program Group-->Manageability-->Instant Capacity','Major Program Group-->Serviceguard-->logicalserverdt')},'source'
    declare_target_table %Q{select * from dbo.ViewCRReporting where dbo.ViewCRReporting.ChangeRequestID in (select FactChangeRequest.ChangeRequestID  from dbo.FactChangeRequest where FactChangeRequest.MappingSchemaID in (Select MappingSchemaID from az.MappingSchema where ParentMappingSchema='860'))},'target'

    #define sourceissueid field's mapping relationship
    mp target.sourceissueid do
        "#{source.internal_system_id}/#{source.system_type.upcase}"
    end

    #define affectedprogramtag field's mapping relationship
    m target.affectedprogramtag do
        if source.AFFECTED_PROGRAMS.nil?
            ''
        else
            source.AFFECTED_PROGRAMS
        end
    end

     m target.organizationunit do
        'MSL'
    end

    #define state field's mapping relationship
    m target.state do
    	if source.state.gsub(/\s|"/, '').downcase=='Awaiting Decision'.gsub(/\s/, '').downcase
    		'Investigating'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Change - Code was incomplete'.gsub(/\s/, '').downcase
    		'Fix Validated'
        elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Change - Code was wrong'.gsub(/\s/, '').downcase
            'Fix Validated'
        elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase&& source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Change - Design was incomplete'.gsub(/\s/, '').downcase
            'Fix Validated'
        elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase&& source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Change - Design was wrong'.gsub(/\s/, '').downcase
            'Fix Validated'
        elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase&& source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Change - Documentation to Disallow'.gsub(/\s/, '').downcase
            'Fix Validated'
        elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase&& source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Change - Documentation to Support'.gsub(/\s/, '').downcase
            'Fix Validated'
        elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase&& source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Change - Item was incomplete'.gsub(/\s/, '').downcase
            'Fix Validated'
        elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase&& source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Change - Item was wrong'.gsub(/\s/, '').downcase
            'Fix Validated'
        elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase&& source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Change - Process was incomplete'.gsub(/\s/, '').downcase
            'Fix Validated'
        elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase&& source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Change - Process was wrong'.gsub(/\s/, '').downcase
            'Fix Validated'
        elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase&& source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Change - Requirements were incomplete'.gsub(/\s/, '').downcase
            'Fix Validated'
        elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase&& source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Change - Requirements were wrong'.gsub(/\s/, '').downcase
            'Fix Validated'
        elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase&& source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Change - Specification was incomplete'.gsub(/\s/, '').downcase
            'Fix Validated'
        elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase&& source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Change - Specification was wrong'.gsub(/\s/, '').downcase
            'Fix Validated'
        elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase&& source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Prov. Closed App/functionality behavior changed'.gsub(/\s/, '').downcase
            'Fix Validated'   
        elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase&& source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Resolution Implemented'.gsub(/\s/, '').downcase
            'Fix Validated'       
        elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase&& source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Change - Non-HP external product/code'.gsub(/\s/, '').downcase
            'Closed'          
        elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase&& source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Change - Test Case was incomplete'.gsub(/\s/, '').downcase
            'Closed'             
        elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase&& source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Change - Test Case was wrong'.gsub(/\s/, '').downcase
            'Closed'           
        elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase&& source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Closed - Insufficient Data'.gsub(/\s/, '').downcase
            'Closed'           
        elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase&& source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Closed - Insufficient Priority'.gsub(/\s/, '').downcase
            'Closed'           
        elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase&& source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Closed - Not Reproducible'.gsub(/\s/, '').downcase
            'Closed'           
        elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase&& source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Closed - Other'.gsub(/\s/, '').downcase
            'Closed'           
        elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase&& source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Closed - Outside of vendor problem'.gsub(/\s/, '').downcase
            'Closed'           
        elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase&& source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Other (see Notes)'.gsub(/\s/, '').downcase
            'Closed'           
        elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase&& source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Prov. Closed Not Reproducible in latest build'.gsub(/\s/, '').downcase
            'Closed'           
        elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase&& source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Prov. Closed Other (see notes)'.gsub(/\s/, '').downcase
            'Closed'           
        elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase&& source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Prov. Closed Test Case was wrong/obsolete'.gsub(/\s/, '').downcase
            'Closed'           
        elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase&& source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Closed - No Change Made'.gsub(/\s/, '').downcase
            'Closed no Change'          
        elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase&& source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Closed - Not a Problem'.gsub(/\s/, '').downcase
            'Closed no Change'        
        elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase&& source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Closed - Not in scope of project'.gsub(/\s/, '').downcase
            'Closed no Change'        
        elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase&& source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Closed - Permanent Defect'.gsub(/\s/, '').downcase
            'Closed no Change'        
        elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase&& source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Closed - User Misunderstanding'.gsub(/\s/, '').downcase
            'Closed no Change'        
        elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase&& source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Prov. Closed Environment Issue'.gsub(/\s/, '').downcase
            'Closed no Change'        
        elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase&& source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Prov. Closed Not Reproducible in same build'.gsub(/\s/, '').downcase
            'Closed no Change'        
        elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase&& source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Prov. Closed Submitter Misunderstanding'.gsub(/\s/, '').downcase
            'Closed no Change' 
        elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Change - Non-HP external product/code'.gsub(/\s/, '').downcase
            'Closed'
        elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Change - Test Case was incomplete'.gsub(/\s/, '').downcase
            'Closed'
        elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Change - Test Case was wrong'.gsub(/\s/, '').downcase
            'Closed'
        elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Closed - Insufficient Data'.gsub(/\s/, '').downcase
            'Closed'
        elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Closed - Insufficient Priority'.gsub(/\s/, '').downcase
            'Closed'
        elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Closed - Not Reproducible'.gsub(/\s/, '').downcase
            'Closed'
        elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Closed - Other'.gsub(/\s/, '').downcase
            'Closed'
        elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Closed - Outside of vendor problem'.gsub(/\s/, '').downcase
            'Closed'
        elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Other (see Notes)'.gsub(/\s/, '').downcase
            'Closed'
        elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Prov. Closed Not Reproducible in latest build'.gsub(/\s/, '').downcase
            'Closed'
        elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Prov. Closed Other (see notes)'.gsub(/\s/, '').downcase
            'Closed'
        elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Prov. Closed Test Case was wrong/obsolete'.gsub(/\s/, '').downcase
            'Closed'
        elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Change - Code was incomplete'.gsub(/\s/, '').downcase
            'Fix Validated'
        elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Change - Code was wrong'.gsub(/\s/, '').downcase
            'Fix Validated'
        elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Change - Design was incomplete'.gsub(/\s/, '').downcase
            'Fix Validated'
        elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Change - Design was wrong'.gsub(/\s/, '').downcase
            'Fix Validated'
        elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Change - Documentation to Disallow'.gsub(/\s/, '').downcase
            'Fix Validated'
        elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Change - Documentation to Support'.gsub(/\s/, '').downcase
            'Fix Validated'
        elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Change - Item was incomplete'.gsub(/\s/, '').downcase
            'Fix Validated'
        elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Change - Item was wrong'.gsub(/\s/, '').downcase
            'Fix Validated'
        elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Change - Process was incomplete'.gsub(/\s/, '').downcase
            'Fix Validated'
        elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Change - Process was wrong'.gsub(/\s/, '').downcase
            'Fix Validated'
        elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Change - Requirements were incomplete'.gsub(/\s/, '').downcase
            'Fix Validated'
        elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Change - Requirements were wrong'.gsub(/\s/, '').downcase
            'Fix Validated'
        elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Change - Specification was incomplete'.gsub(/\s/, '').downcase
            'Fix Validated'
        elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Change - Specification was wrong'.gsub(/\s/, '').downcase
            'Fix Validated'
        elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Prov. Closed App/functionality behavior changed'.gsub(/\s/, '').downcase
            'Fix Validated'
        elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Resolution Implemented'.gsub(/\s/, '').downcase
            'Fix Validated'
        elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Closed - No Change Made'.gsub(/\s/, '').downcase
            'Closed no Change'
        elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Closed - Not a Problem'.gsub(/\s/, '').downcase
            'Closed no Change'
        elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Closed - Not in scope of project'.gsub(/\s/, '').downcase
            'Closed no Change'
        elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Closed - Permanent Defect'.gsub(/\s/, '').downcase
            'Closed no Change'
        elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Closed - User Misunderstanding'.gsub(/\s/, '').downcase
            'Closed no Change'
        elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Prov. Closed Environment Issue'.gsub(/\s/, '').downcase
            'Closed no Change'
        elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Prov. Closed Not Reproducible in same build'.gsub(/\s/, '').downcase
            'Closed no Change'
        elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Prov. Closed Submitter Misunderstanding'.gsub(/\s/, '').downcase
            'Closed no Change'
        elsif source.state.gsub(/\s|"/, '').downcase=='Deferred'.gsub(/\s/, '').downcase
            'Deferred'
        elsif source.state.gsub(/\s|"/, '').downcase=='Closed-No Change'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Closed - No Change Made'.gsub(/\s/, '').downcase
            'Closed no Change'
        elsif source.state.gsub(/\s|"/, '').downcase=='Closed-No Change'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Closed - Not a Problem'.gsub(/\s/, '').downcase
            'Closed no Change'
        elsif source.state.gsub(/\s|"/, '').downcase=='Closed-No Change'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Closed - Not in scope of project'.gsub(/\s/, '').downcase
            'Closed no Change'
        elsif source.state.gsub(/\s|"/, '').downcase=='Closed-No Change'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Closed - Permanent Defect'.gsub(/\s/, '').downcase
            'Closed no Change'
        elsif source.state.gsub(/\s|"/, '').downcase=='Closed-No Change'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Closed - User Misunderstanding'.gsub(/\s/, '').downcase
            'Closed no Change'
        elsif source.state.gsub(/\s|"/, '').downcase=='Closed-No Change'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Prov. Closed Environment Issue'.gsub(/\s/, '').downcase
            'Closed no Change'
        elsif source.state.gsub(/\s|"/, '').downcase=='Closed-No Change'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Prov. Closed Not Reproducible in same build'.gsub(/\s/, '').downcase
            'Closed no Change'
        elsif source.state.gsub(/\s|"/, '').downcase=='Closed-No Change'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Prov. Closed Submitter Misunderstanding'.gsub(/\s/, '').downcase
            'Closed no Change'
        elsif source.state.gsub(/\s|"/, '').downcase=='Closed-No Change'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Change - Non-HP external product/code'.gsub(/\s/, '').downcase
            'Closed'
        elsif source.state.gsub(/\s|"/, '').downcase=='Closed-No Change'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Change - Test Case was incomplete'.gsub(/\s/, '').downcase
            'Closed'
        elsif source.state.gsub(/\s|"/, '').downcase=='Closed-No Change'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Change - Test Case was wrong'.gsub(/\s/, '').downcase
            'Closed'
        elsif source.state.gsub(/\s|"/, '').downcase=='Closed-No Change'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Closed - Insufficient Data'.gsub(/\s/, '').downcase
            'Closed'
        elsif source.state.gsub(/\s|"/, '').downcase=='Closed-No Change'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Closed - Insufficient Priority'.gsub(/\s/, '').downcase
            'Closed'
        elsif source.state.gsub(/\s|"/, '').downcase=='Closed-No Change'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Closed - Not Reproducible'.gsub(/\s/, '').downcase
            'Closed'
        elsif source.state.gsub(/\s|"/, '').downcase=='Closed-No Change'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Closed - Other'.gsub(/\s/, '').downcase
            'Closed'
        elsif source.state.gsub(/\s|"/, '').downcase=='Closed-No Change'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Closed - Outside of vendor problem'.gsub(/\s/, '').downcase
            'Closed'
        elsif source.state.gsub(/\s|"/, '').downcase=='Closed-No Change'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Other (see Notes)'.gsub(/\s/, '').downcase
            'Closed'
        elsif source.state.gsub(/\s|"/, '').downcase=='Closed-No Change'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Prov. Closed Not Reproducible in latest build'.gsub(/\s/, '').downcase
            'Closed'
        elsif source.state.gsub(/\s|"/, '').downcase=='Closed-No Change'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Prov. Closed Other (see notes)'.gsub(/\s/, '').downcase
            'Closed'
        elsif source.state.gsub(/\s|"/, '').downcase=='Closed-No Change'.gsub(/\s/, '').downcase && source.DISPOSITION_CLASSIFICATION.gsub(/\s|"/, '').downcase=='Prov. Closed Test Case was wrong/obsolete'.gsub(/\s/, '').downcase
            'Closed'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Support Review'.gsub(/\s/, '').downcase
    		'New'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Development'.gsub(/\s/, '').downcase
    		'Being Fixed'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Duplicate'.gsub(/\s/, '').downcase
    		'Duplicate'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Lab Review'.gsub(/\s/, '').downcase
    		'New'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Testing'.gsub(/\s/, '').downcase
    		'Validating Fix'
        else 
            if source.state.nil? && source.DISPOSITION_CLASSIFICATION.nil?
                ''
            elsif !source.state.nil? && source.DISPOSITION_CLASSIFICATION.nil?
                source.state
            elsif source.state.nil? && !source.DISPOSITION_CLASSIFICATION.nil?
                source.DISPOSITION_CLASSIFICATION
            else
                "#{source.state}/#{source.DISPOSITION_CLASSIFICATION}"
            end
    	end
    end

    #define customerencountered field's mapping relationship
    m target.customerencountered do
    	case 
    	when source.customer_encountered_flag.gsub(/\s|"/, '').downcase=='N'.gsub(/\s/, '').downcase
    		'N'
    	when source.customer_encountered_flag.gsub(/\s|"/, '').downcase=='Y'.gsub(/\s/, '').downcase
    		'Y'
        else
            ' '
    	end
    end

    #define customerseverity field's mapping relationship
    m target.customerseverity do
    	if source.severity.gsub(/\s|"/, '').downcase=='Critical'.gsub(/\s/, '').downcase
    		'Critical'
    	elsif source.severity.gsub(/\s|"/, '').downcase=='Low'.gsub(/\s/, '').downcase
    		'Low'
    	elsif source.severity.gsub(/\s|"/, '').downcase=='Medium'.gsub(/\s/, '').downcase
    		'Medium'
    	elsif source.severity.gsub(/\s|"/, '').downcase=='Serious'.gsub(/\s/, '').downcase
    		'Serious'
        elsif source.severity.nil?
            ''
    	else
    		source.severity
    	end
    end

    #define dispositionclassification field's mapping relationship
    m target.dispositionclassification do
    	if source.disposition_classification.gsub(/\s|"/, '').downcase=='Change - Code was incomplete'.gsub(/\s/, '').downcase
    		'Code Change'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Change - Code was wrong'.gsub(/\s/, '').downcase
    		'Code Change'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Change - Design was incomplete'.gsub(/\s/, '').downcase
    		'Design Change'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Change - Design was wrong'.gsub(/\s/, '').downcase
    		'Incorrect Design'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Change - Documentation to Disallow'.gsub(/\s/, '').downcase
    		'Documentation Change'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Change - Documentation to Support'.gsub(/\s/, '').downcase
    		'Documentation Change'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Change - Item was incomplete'.gsub(/\s/, '').downcase
    		'Code Change'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Change - Item was wrong'.gsub(/\s/, '').downcase
    		'Code Change'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Change - Non-HP external product/code'.gsub(/\s/, '').downcase
    		'3rd Party Product'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Change - Process was incomplete'.gsub(/\s/, '').downcase
    		'Process Change'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Change - Process was wrong'.gsub(/\s/, '').downcase
    		'Process Change'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Change - Requirements were incomplete'.gsub(/\s/, '').downcase
    		'Requirements Change'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Change - Requirements were wrong'.gsub(/\s/, '').downcase
    		'Specification Change'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Change - Specification was incomplete'.gsub(/\s/, '').downcase
    		'Specification Change'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Change - Specification was wrong'.gsub(/\s/, '').downcase
    		'Specification Change'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Change - Test Case was incomplete'.gsub(/\s/, '').downcase
    		'Incorrect Test Plan'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Change - Test Case was wrong'.gsub(/\s/, '').downcase
    		'Incorrect Test Plan'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Insufficient Data'.gsub(/\s/, '').downcase
    		'Insufficient Data'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Insufficient Priority'.gsub(/\s/, '').downcase
    		'Insufficient Priority'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - No Change Made'.gsub(/\s/, '').downcase
    		'Not a Problem'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Not a Problem'.gsub(/\s/, '').downcase
    		'Not a Problem'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Not in scope of project'.gsub(/\s/, '').downcase
    		'Out of Scope'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Not Reproducible'.gsub(/\s/, '').downcase
    		'Not Reproducible'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Other'.gsub(/\s/, '').downcase
    		'Other'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Outside of vendor problem'.gsub(/\s/, '').downcase
    		'Incorrect Design'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Permanent Defect'.gsub(/\s/, '').downcase
    		'Do Not Fix'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - User Misunderstanding'.gsub(/\s/, '').downcase
    		'User Misunderstanding'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Other (see Notes)'.gsub(/\s/, '').downcase
    		'Other'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Prov. Closed App/functionality behavior changed'.gsub(/\s/, '').downcase
    		'Design Change'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Prov. Closed Environment Issue'.gsub(/\s/, '').downcase
    		'User Misunderstanding'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Prov. Closed Not Reproducible in latest build'.gsub(/\s/, '').downcase
    		'Not Reproducible'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Prov. Closed Not Reproducible in same build'.gsub(/\s/, '').downcase
    		'Not Reproducible'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Prov. Closed Other (see notes)'.gsub(/\s/, '').downcase
    		'Other'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Prov. Closed Submitter Misunderstanding'.gsub(/\s/, '').downcase
    		'User Misunderstanding'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Prov. Closed Test Case was wrong/obsolete'.gsub(/\s/, '').downcase
    		'Incorrect Test Plan'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Resolution Implemented'.gsub(/\s/, '').downcase
    		'Code Change'
        elsif source.disposition_classification.nil?
            ''
    	else 
    		source.disposition_classification
    	end
    end

    #define engineeringpriority field's mapping relationship
    #m target.engineeringpriority do
    #	case 
	 #   	when source.engineering_priority.gsub(/\s|"/, '').downcase=='High'.gsub(/\s/, '').downcase
	  #  		'High'
	   # 	when source.engineering_priority.gsub(/\s|"/, '').downcase=='Low'.gsub(/\s/, '').downcase
	    ##		'Low'
	    #	when source.engineering_priority.gsub(/\s|"/, '').downcase=='Medium'.gsub(/\s/, '').downcase
	    #		'Medium'
         #   else
          #      ''
    	#end
    #end

    #define forecastofcustomerbaseencountering field's mapping relationship
    m target.forecastofcustomerbaseencountering do
    	case 
    		when source.visibility.gsub(/\s|"/, '').downcase=='Lab & Support'.gsub(/\s/, '').downcase
    			'Y'
    		when source.visibility.gsub(/\s|"/, '').downcase=='Lab Only'.gsub(/\s/, '').downcase
    			'N'
    		when source.visibility.gsub(/\s|"/, '').downcase=='Lab, Support & Customer'.gsub(/\s/, '').downcase
    			'Y'
            else
                ' '
    	end
    end

    #define possibilityofcustomeroccurrence field's mapping relationship
    m target.possibilityofcustomeroccurrence do
    	if source.engineering_priority.gsub(/\s|"/, '').downcase=='High'.gsub(/\s/, '').downcase
    		'Always'
    	elsif source.engineering_priority.gsub(/\s|"/, '').downcase=='Low'.gsub(/\s/, '').downcase
    		'Unlikely'
    	elsif source.engineering_priority.gsub(/\s|"/, '').downcase=='Medium'.gsub(/\s/, '').downcase
    		'Very Likely'
        elsif source.engineering_priority.nil?
            ''
    	else
    		source.engineering_priority
    	end
    end

    #define foundinstep field's mapping relationship
    m target.foundinstep do
    	if source.found_in_phase.gsub(/\s|"/, '').downcase==' Requirements Analysis and Planning (RA&P)'.gsub(/\s/, '').downcase
    		'Requirement Review'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Code and Unit Test (CUT)'.gsub(/\s/, '').downcase
    		'Implementation'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Component Integration Test'.gsub(/\s/, '').downcase
    		'Test'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Component Test'.gsub(/\s/, '').downcase
    		'Implementation'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Construction'.gsub(/\s/, '').downcase
    		'Investigation'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Customer Requirements Test'.gsub(/\s/, '').downcase
    		'Test'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Design'.gsub(/\s/, '').downcase
    		'Design'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Detailed Design (DD)'.gsub(/\s/, '').downcase
    		'Design'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Early Partner Int Test'.gsub(/\s/, '').downcase
    		'Test'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Early System Test'.gsub(/\s/, '').downcase
    		'Test'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Elaboration'.gsub(/\s/, '').downcase
    		'Investigation'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Final System Test'.gsub(/\s/, '').downcase
    		'Test'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='High Level Design (HLD)'.gsub(/\s/, '').downcase
    		'Design'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='ILC: Post Release'.gsub(/\s/, '').downcase
    		'Post Release'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='ILC: Product Planning'.gsub(/\s/, '').downcase
    		'Design'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='ILC: Project Execution'.gsub(/\s/, '').downcase
    		'Implementation'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='ILC: Project Planning'.gsub(/\s/, '').downcase
    		'Requirement Review'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='ILC: Requirements'.gsub(/\s/, '').downcase
    		'Requirement Review'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Implementation'.gsub(/\s/, '').downcase
    		'Implementation'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Inception'.gsub(/\s/, '').downcase
    		'Requirement Review'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Integration Test (IT)'.gsub(/\s/, '').downcase
    		'Test'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Investigation'.gsub(/\s/, '').downcase
    		'Investigation'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='MAT'.gsub(/\s/, '').downcase
    		'Implementation'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='N/A'.gsub(/\s/, '').downcase
    		'Unknown'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='ODC: Code Review'.gsub(/\s/, '').downcase
    		'Implementation'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='ODC: Component Testing'.gsub(/\s/, '').downcase
    		'Implementation'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='ODC: Customer/Regular Use'.gsub(/\s/, '').downcase
    		'Post Release'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='ODC: Design Review'.gsub(/\s/, '').downcase
    		'Design'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='ODC: Integration Testing'.gsub(/\s/, '').downcase
    		'Test'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='ODC: Solution Testing'.gsub(/\s/, '').downcase
    		'Test'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='ODC: System Testing'.gsub(/\s/, '').downcase
    		'Test'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='ODC: Unit Testing'.gsub(/\s/, '').downcase
    		'Implementation'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Other'.gsub(/\s/, '').downcase
    		'Unknown'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Partner Integration Test'.gsub(/\s/, '').downcase
    		'Test'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Partner Testing'.gsub(/\s/, '').downcase
    		'Test'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Patch Testing'.gsub(/\s/, '').downcase
    		'Test'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Post Release'.gsub(/\s/, '').downcase
    		'Post Release'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Project Initiation (PI)'.gsub(/\s/, '').downcase
    		'Initialization'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Release'.gsub(/\s/, '').downcase
    		'Post Release'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Release (REL)'.gsub(/\s/, '').downcase
    		'Post Release'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Requirements'.gsub(/\s/, '').downcase
    		'Requirement Review'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='System Test'.gsub(/\s/, '').downcase
    		'Test'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='System Test (ST)'.gsub(/\s/, '').downcase
    		'Test'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Test'.gsub(/\s/, '').downcase
    		'Test'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Verification'.gsub(/\s/, '').downcase
    		'Test'
        elsif source.found_in_phase.nil?
            ''
    	else
    		source.found_in_phase
    	end
    end

    #define project field's mapping relationship
    m target.project do
        if source.project_hierarchy.nil?
            ''
        else
            source.project_hierarchy
        end
    end

    #define product field's mapping relationship
    m target.product do 
        if source.product.nil?
            ''
        else
            source.product
        end
    end

    #define qablocker field's mapping relationship
    m target.qablocker do
    	case 
	    	when source.selection_1.gsub(/\s|"/, '').downcase=='Blocking'.gsub(/\s/, '').downcase
	    		'Y'
	    	when source.selection_1.gsub(/\s|"/, '').downcase=='Blocking-High'.gsub(/\s/, '').downcase
	    		'Y'
	    	when source.selection_1.gsub(/\s|"/, '').downcase=='Blocking-Low'.gsub(/\s/, '').downcase
	    		'Y'
	    	when source.selection_1.gsub(/\s|"/, '').downcase=='Blocking-Med'.gsub(/\s/, '').downcase
	    		'Y'
	    	when source.selection_1.gsub(/\s|"/, '').downcase=='IS Blocking-High'.gsub(/\s/, '').downcase
	    		'Y'
	    	when source.selection_1.gsub(/\s|"/, '').downcase=='IS Blocking-Low'.gsub(/\s/, '').downcase
	    		'Y'
	    	when source.selection_1.gsub(/\s|"/, '').downcase=='IS Blocking-Med'.gsub(/\s/, '').downcase
	    		'Y'
	    	when source.selection_1.gsub(/\s|"/, '').downcase=='Not blocking'.gsub(/\s/, '').downcase
	    		'N'
	    	when source.selection_1.gsub(/\s|"/, '').downcase=='Tracking'.gsub(/\s/, '').downcase
	    		'N'  	
            else
                ' '	
    	end
    end

    #define changerequesttype field's mapping relationship
    m target.changerequesttype do
    	if source.issuetype.gsub(/\s|"/, '').downcase=='Defect'.gsub(/\s/, '').downcase
    		'Defect'
    	elsif source.issuetype.gsub(/\s|"/, '').downcase=='Enhancement'.gsub(/\s/, '').downcase
    		'Enhancement'
        elsif source.issuetype.nil?
            ''
    	else 
    		source.issuetype
    	end
    end

end
