require 'etltester'
mapping("QUIX_HW_VSB_Mapping") do



    #Using keyword define_variables to define variable checkpointendtime.
    #define_variable :checkpointendtime do
    #    Util::DBConnection.get_data_from_db Uti::Configuration::get_config(:DBConnection,
    #        'select max(checkpointendtime) from az.MappingSchemaLoadingAudit where MappingSchemaID=861 and CurrentStatus=\'succeed\'')[0][0]
    #end
    #{variables[:checkpointendtime]}

    # declare table will be used in ETL for QUIX Component
    # Notes:
    #       1.Please update projects in source SQL if needed
    set_source_connection :oracle_QUIX_connection
    #source_db_connection = :oracle_QUIX_connection
    declare_source_table %Q{select count(*) from BO_QX_CR where  submitdate<= to_date('2013-07-31 07:50:08','YYYY-MM-DD HH24:MI:SS') and  BO_QX_CR.PROJECT_HIERARCHY in('Base Project-->HP-->TSG-->ESS-->VSB-->ICE-Linux','Base Project-->HP-->TSG-->ESS-->VSB-->Version Control Agent','Base Project-->HP-->TSG-->ESS-->VSB-->VMM','Base Project-->HP-->TSG-->ESS-->VSB-->PMP','Base Project-->HP-->TSG-->ESS-->VSB-->ISF Trackers','Base Project-->HP-->TSG-->ESS-->VSB-->Version Control Repository Mngr','Base Project-->HP-->TSG-->ESS-->VSB-->Dobby','Base Project-->HP-->TSG-->ESS-->VSB-->HP SIM','Base Project-->HP-->TSG-->ESS-->VSB-->Insight Software DVD','Base Project-->HP-->TSG-->ESS-->VSB-->System Management Homepage','Base Project-->HP-->TSG-->ESS-->VSB-->AresLite','Base Project-->HP-->TSG-->ESS-->VSB-->SMP','Base Project-->HP-->TSG-->ESS-->VSB-->Insight Power Manager','Base Project-->HP-->TSG-->ESS-->VSB-->RDP','Base Project-->HP-->TSG-->ESS-->VSB-->Yeti','Base Project-->HP-->TSG-->ESS-->VSB-->WMI Mapper')},'source'
    declare_target_table %Q{select * from dbo.ViewCRReporting where dbo.ViewCRReporting.ChangeRequestID in (select FactChangeRequest.ChangeRequestID  from dbo.FactChangeRequest where FactChangeRequest.MappingSchemaID in (Select MappingSchemaID from az.MappingSchema where ParentMappingSchema='929'))},'target'

    #define sourceissueid field's mapping relationship
    mp target.sourceissueid do
        "#{source.internal_system_id}/#{source.system_type.upcase}"
    end

    m target.organizationunit do
        'VSB'
    end

    #define state field's mapping relationship
    m target.state do
    	if source.state.gsub(/\s|"/, '').downcase=='Lab Review'.gsub(/\s/, '').downcase
    		'New'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Support Review'.gsub(/\s/, '').downcase
    		'New'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Development'.gsub(/\s/, '').downcase
    		'Being Fixed'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Decision'.gsub(/\s/, '').downcase
    		'Investigating'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Testing'.gsub(/\s/, '').downcase
    		'Validating Fix'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Resolution Implemented'.gsub(/\s/, '').downcase
    		'Fix Validated'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Code Change'.gsub(/\s/, '').downcase
    		'Fix Validated'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Documentation'.gsub(/\s/, '').downcase
    		'Fix Validated'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Documentation Change or Training'.gsub(/\s/, '').downcase
    		'Fix Validated'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Fixed'.gsub(/\s/, '').downcase
    		'Fix Validated'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Guides or Whitepaper Change'.gsub(/\s/, '').downcase
    		'Fix Validated'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Release Notes/Readme Change'.gsub(/\s/, '').downcase
    		'Fix Validated'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Specification Change'.gsub(/\s/, '').downcase
    		'Fix Validated'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Workaround is solution'.gsub(/\s/, '').downcase
    		'Fix Validated'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='"Other"'.gsub(/\s/, '').downcase
    		'Closed'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='"Unable to reproduce"'.gsub(/\s/, '').downcase
    		'Closed'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='3rd Party Product'.gsub(/\s/, '').downcase
    		'Closed'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Can Not Duplicate'.gsub(/\s/, '').downcase
    		'Closed'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Insufficient Data'.gsub(/\s/, '').downcase
    		'Closed'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Other'.gsub(/\s/, '').downcase
    		'Closed'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Not Reproducible'.gsub(/\s/, '').downcase
    		'Closed'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Outside vendor problem'.gsub(/\s/, '').downcase
    		'Closed'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Forward to Vendor'.gsub(/\s/, '').downcase
    		'Closed'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Merged with another problem'.gsub(/\s/, '').downcase
    		'Closed'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Other'.gsub(/\s/, '').downcase
    		'Closed'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Referred to another project'.gsub(/\s/, '').downcase
    		'Closed'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Unable to Reproduce'.gsub(/\s/, '').downcase
    		'Closed'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='"User misunderstanding"'.gsub(/\s/, '').downcase
    		'Closed no Change'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Not a Problem'.gsub(/\s/, '').downcase
    		'Closed no Change'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Not in scope of project'.gsub(/\s/, '').downcase
    		'Closed no Change'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Do Not Fix'.gsub(/\s/, '').downcase
    		'Closed no Change'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='No plans to implement'.gsub(/\s/, '').downcase
    		'Closed no Change'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Not in Project Scope'.gsub(/\s/, '').downcase
    		'Closed no Change'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Will Not Fix'.gsub(/\s/, '').downcase
    		'Closed no Change'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='User Misunderstanding'.gsub(/\s/, '').downcase
    		'Closed no Change'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Duplicate problem'.gsub(/\s/, '').downcase
    		'Duplicate'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Duplicate'.gsub(/\s/, '').downcase
    		'Duplicate'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Awaiting Release'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Deferred '.gsub(/\s/, '').downcase
    		'Deferred'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Resolution Implemented'.gsub(/\s/, '').downcase
    		'Fix Validated'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Code Change'.gsub(/\s/, '').downcase
    		'Fix Validated'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Documentation'.gsub(/\s/, '').downcase
    		'Fix Validated'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Documentation Change or Training'.gsub(/\s/, '').downcase
    		'Fix Validated'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Fixed'.gsub(/\s/, '').downcase
    		'Fix Validated'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Guides or Whitepaper Change'.gsub(/\s/, '').downcase
    		'Fix Validated'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Release Notes/Readme Change'.gsub(/\s/, '').downcase
    		'Fix Validated'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Specification Change'.gsub(/\s/, '').downcase
    		'Fix Validated'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Workaround is solution'.gsub(/\s/, '').downcase
    		'Fix Validated'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='"Other"'.gsub(/\s/, '').downcase
    		'Closed'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='"Unable to reproduce"'.gsub(/\s/, '').downcase
    		'Closed'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='3rd Party Product'.gsub(/\s/, '').downcase
    		'Closed'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Can Not Duplicate'.gsub(/\s/, '').downcase
    		'Closed'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Insufficient Data'.gsub(/\s/, '').downcase
    		'Closed'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Other'.gsub(/\s/, '').downcase
    		'Closed'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Not Reproducible'.gsub(/\s/, '').downcase
    		'Closed'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Outside vendor problem'.gsub(/\s/, '').downcase
    		'Closed'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Forward to Vendor'.gsub(/\s/, '').downcase
    		'Closed'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Merged with another problem'.gsub(/\s/, '').downcase
    		'Closed'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Other'.gsub(/\s/, '').downcase
    		'Closed'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Referred to another project'.gsub(/\s/, '').downcase
    		'Closed'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Unable to Reproduce'.gsub(/\s/, '').downcase
    		'Closed'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='"User misunderstanding"'.gsub(/\s/, '').downcase
    		'Closed no Change'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Not a Problem'.gsub(/\s/, '').downcase
    		'Closed no Change'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Not in scope of project'.gsub(/\s/, '').downcase
    		'Closed no Change'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Do Not Fix'.gsub(/\s/, '').downcase
    		'Closed no Change'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='No plans to implement'.gsub(/\s/, '').downcase
    		'Closed no Change'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Not in Project Scope'.gsub(/\s/, '').downcase
    		'Closed no Change'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Will Not Fix'.gsub(/\s/, '').downcase
    		'Closed no Change'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='User Misunderstanding'.gsub(/\s/, '').downcase
    		'Closed no Change'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Duplicate problem'.gsub(/\s/, '').downcase
    		'Duplicate'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Duplicate'.gsub(/\s/, '').downcase
    		'Duplicate'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Deferred'.gsub(/\s/, '').downcase
    		'Deferred'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Deferred'.gsub(/\s/, '').downcase
    		'Deferred'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Duplicate'.gsub(/\s/, '').downcase
    		'Duplicate'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Closed-No Change'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='"User misunderstanding"'.gsub(/\s/, '').downcase
    		'Closed no Change'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Closed-No Change'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Not a Problem'.gsub(/\s/, '').downcase
    		'Closed no Change'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Closed-No Change'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Not in scope of project'.gsub(/\s/, '').downcase
    		'Closed no Change'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Closed-No Change'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Do Not Fix'.gsub(/\s/, '').downcase
    		'Closed no Change'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Closed-No Change'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='No plans to implement'.gsub(/\s/, '').downcase
    		'Closed no Change'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Closed-No Change'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Not in Project Scope'.gsub(/\s/, '').downcase
    		'Closed no Change'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Closed-No Change'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Will Not Fix'.gsub(/\s/, '').downcase
    		'Closed no Change'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Closed-No Change'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='User Misunderstanding'.gsub(/\s/, '').downcase
    		'Closed no Change'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Closed-No Change'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='"Other"'.gsub(/\s/, '').downcase
    		'Closed'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Closed-No Change'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='"Unable to reproduce"'.gsub(/\s/, '').downcase
    		'Closed'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Closed-No Change'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='3rd Party Product'.gsub(/\s/, '').downcase
    		'Closed'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Closed-No Change'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Can Not Duplicate'.gsub(/\s/, '').downcase
    		'Closed'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Closed-No Change'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Insufficient Data'.gsub(/\s/, '').downcase
    		'Closed'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Closed-No Change'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Other'.gsub(/\s/, '').downcase
    		'Closed'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Closed-No Change'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Not Reproducible'.gsub(/\s/, '').downcase
    		'Closed'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Closed-No Change'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Outside vendor problem'.gsub(/\s/, '').downcase
    		'Closed'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Closed-No Change'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Forward to Vendor'.gsub(/\s/, '').downcase
    		'Closed'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Closed-No Change'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Merged with another problem'.gsub(/\s/, '').downcase
    		'Closed'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Closed-No Change'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Other'.gsub(/\s/, '').downcase
    		'Closed'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Closed-No Change'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Referred to another project'.gsub(/\s/, '').downcase
    		'Closed'
    	elsif source.state.gsub(/\s|"/, '').downcase=='Closed-No Change'.gsub(/\s/, '').downcase && source.disposition_classification.gsub(/\s|"/, '').downcase=='Unable to Reproduce'.gsub(/\s/, '').downcase
    		'Closed'
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

    m target.DispositionClassification do
    	if source.disposition_classification.gsub(/\s|"/, '').downcase=='"Other"'.gsub(/\s/, '').downcase
    		'Other'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='"Unable to reproduce"'.gsub(/\s/, '').downcase
    		'Not Reproducible'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='"User misunderstanding"'.gsub(/\s/, '').downcase
    		'User Misunderstanding'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='3rd Party Product'.gsub(/\s/, '').downcase
    		'3rd Party Product'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Can Not Duplicate'.gsub(/\s/, '').downcase
    		'Not Reproducible'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Duplicate problem'.gsub(/\s/, '').downcase
    		'Duplicate Problem'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Insufficient Data'.gsub(/\s/, '').downcase
    		'Insufficient Data'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Not a Problem'.gsub(/\s/, '').downcase
    		'Not a Problem'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Not in scope of project'.gsub(/\s/, '').downcase
    		'Out of Scope'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Other'.gsub(/\s/, '').downcase
    		'Other'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Not Reproducible'.gsub(/\s/, '').downcase
    		'Not Reproducible'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Outside vendor problem'.gsub(/\s/, '').downcase
    		'Forward to Vendor'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Resolution Implemented'.gsub(/\s/, '').downcase
    		'Code Change'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Code Change'.gsub(/\s/, '').downcase
    		'Code Change'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Deferred'.gsub(/\s/, '').downcase
    		'Deferred'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Do Not Fix'.gsub(/\s/, '').downcase
    		'Do Not Fix'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Documentation'.gsub(/\s/, '').downcase
    		'Documentation Change'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Documentation Change or Training'.gsub(/\s/, '').downcase
    		'Documentation Change'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Duplicate'.gsub(/\s/, '').downcase
    		'Duplicate Problem'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='FDR14550'.gsub(/\s/, '').downcase
    		'Other'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Fixed'.gsub(/\s/, '').downcase
    		'Code Change'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Forward to Vendor'.gsub(/\s/, '').downcase
    		'Forward to Vendor'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Guides or Whitepaper Change'.gsub(/\s/, '').downcase
    		'Documentation Change'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Information added'.gsub(/\s/, '').downcase
    		'Insufficient Data'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Merged with another problem'.gsub(/\s/, '').downcase
    		'Merged with Another'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='No plans to implement'.gsub(/\s/, '').downcase
    		'Not Implemented'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Not in Project Scope'.gsub(/\s/, '').downcase
    		'Out of Scope'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Other'.gsub(/\s/, '').downcase
    		'Other'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Pending Documentation'.gsub(/\s/, '').downcase
    		'Other'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Question answered'.gsub(/\s/, '').downcase
    		'Insufficient Data'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Referred to another project'.gsub(/\s/, '').downcase
    		'Merged with Another'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='See Legacy Attachment'.gsub(/\s/, '').downcase
    		'Other'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Specification Change'.gsub(/\s/, '').downcase
    		'Specification Change'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Unable to Reproduce'.gsub(/\s/, '').downcase
    		'Not Reproducible'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='User Misunderstanding'.gsub(/\s/, '').downcase
    		'User Misunderstanding'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Will Not Fix'.gsub(/\s/, '').downcase
    		'Do Not Fix'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Workaround is solution'.gsub(/\s/, '').downcase
    		'Other'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Need More Information'.gsub(/\s/, '').downcase
    		'Insufficient Data'
    	elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Release Notes/Readme Change'.gsub(/\s/, '').downcase
    		'Documentation Change'
    	elsif source.disposition_classification.nil?
    		''
    	else
    		source.disposition_classification
    	end
    end

    m target.foundinstep do
    	if source.found_in_phase.gsub(/\s|"/, '').downcase=='Component Dev Test'.gsub(/\s/, '').downcase
    		'Implementation'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Component Integration Test'.gsub(/\s/, '').downcase
    		'Test'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Component Test'.gsub(/\s/, '').downcase
    		'Implementation'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Customer Requirements Test'.gsub(/\s/, '').downcase
    		'Test'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='development'.gsub(/\s/, '').downcase
    		'Implementation'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Early System Test'.gsub(/\s/, '').downcase
    		'Test'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Final System Test'.gsub(/\s/, '').downcase
    		'Test'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='IST Phase 0'.gsub(/\s/, '').downcase
    		'Test'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='IST Phase 1'.gsub(/\s/, '').downcase
    		'Test'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='IST Phase 2'.gsub(/\s/, '').downcase
    		'Test'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='IST Phase 3'.gsub(/\s/, '').downcase
    		'Test'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Partner testing'.gsub(/\s/, '').downcase
    		'Test'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Peer Review - Definition'.gsub(/\s/, '').downcase
    		'Requirement Review'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Peer Review - Development'.gsub(/\s/, '').downcase
    		'Implementation'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Peer Review - Validation'.gsub(/\s/, '').downcase
    		'Implementation'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Phase 0=Initiation'.gsub(/\s/, '').downcase
    		'Initialization'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Phase 1=Investigation'.gsub(/\s/, '').downcase
    		'Initialization'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Phase 2=Design'.gsub(/\s/, '').downcase
    		'Design'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Phase 3=Implementation'.gsub(/\s/, '').downcase
    		'Implementation'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Phase 4.1=Alpha Test'.gsub(/\s/, '').downcase
    		'Implementation'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Phase 4.2=Beta Test'.gsub(/\s/, '').downcase
    		'Test'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Phase 4.3=Partner Test'.gsub(/\s/, '').downcase
    		'Test'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Phase 4.4=DP Test'.gsub(/\s/, '').downcase
    		'Test'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Phase 4=Test'.gsub(/\s/, '').downcase
    		'Test'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Phase 5=Post-Release'.gsub(/\s/, '').downcase
    		'Post Release'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Post Release'.gsub(/\s/, '').downcase
    		'Post Release'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='post-release'.gsub(/\s/, '').downcase
    		'Post Release'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Requirements Review - Concept'.gsub(/\s/, '').downcase
    		'Requirement Review'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Solution Test'.gsub(/\s/, '').downcase
    		'Test'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='System Test'.gsub(/\s/, '').downcase
    		'Test'
    	elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Test'.gsub(/\s/, '').downcase
    		'Test'
    	elsif source.found_in_phase.nil?
    		''
    	else
    		source.found_in_phase
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

	#define customerseverity fiels'd mapping relationship
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

    
    #define customerencountered field's mapping relationship
    m target.customerencountered do
    	if source.customer_encountered_flag.gsub(/\s|"/, '').downcase=='Y'.gsub(/\s/, '').downcase
    		'Y'
    	elsif  source.customer_encountered_flag.gsub(/\s|"/, '').downcase=='N'.gsub(/\s/, '').downcase
    		'N'
        elsif source.customer_encountered_flag.nil?
            ' '
    	else
    		 source.customer_encountered_flag
    	end
    end

    #define possibilityofcustomeroccurrence field's mapping relationship
    m target.possibilityofcustomeroccurrence do
    	if source.REPEATABILITY.gsub(/\s|"/, '').downcase=='High Probability'.gsub(/\s/, '').downcase
    		'Always' 
    	elsif source.REPEATABILITY.gsub(/\s|"/, '').downcase=='Med Probability' .gsub(/\s/, '').downcase
    		'Very Likely'
    	elsif source.REPEATABILITY.gsub(/\s|"/, '').downcase=='Low Probability'.gsub(/\s/, '').downcase
    		'Unlikely'
    	elsif source.REPEATABILITY.gsub(/\s|"/, '').downcase=='Intermittent'.gsub(/\s/, '').downcase
    		'Likely'
    	elsif source.REPEATABILITY.gsub(/\s|"/, '').downcase=='One Time Occurrence'.gsub(/\s/, '').downcase
    		'Unlikely'
    	elsif source.REPEATABILITY.gsub(/\s|"/, '').downcase=='Recurring'.gsub(/\s/, '').downcase
    		'Always'
    	elsif source.REPEATABILITY.gsub(/\s|"/, '').downcase=='Unknown'.gsub(/\s/, '').downcase
    		'N/A'
        elsif source.REPEATABILITY.nil?
            ''
    	else
    		 source.REPEATABILITY
    	end
    end    
    
    #define forecastofcustomerbaseencountering  field's mapping relationship
    m target.forecastofcustomerbaseencountering do
        case 
            when source.visibility.gsub(/\s|"/, '').downcase=='Lab only'.gsub(/\s/, '').downcase
                'N'
            when source.visibility.gsub(/\s|"/, '').downcase=='Lab, Support & Customer'.gsub(/\s/, '').downcase
                'Y'
            when source.visibility.gsub(/\s|"/, '').downcase=='Lab & Support'.gsub(/\s/, '').downcase.gsub(/\s/, '').downcase
                'Y'
            else
                ' '
        end
    end

    #define qablocker field's mapping relationship
    m target.qablocker do
    	case 
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

    #define project field's mapping relationship
    m target.project do
        if source.project_hierarchy.nil?
            ''
        else
            source.project_hierarchy
        end
    end

    m target.affectedprogramtag do
        if source.affected_programs.nil?
            ''
        else 
            source.affected_programs
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


end
