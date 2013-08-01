require 'etltester'
mapping("StoreAll_Mapping") do


    #Using keyword define_variables to define variable checkpointendtime.
    define_variable :checkpointendtime do
        Util::DBConnection.get_data_from_db Uti::Configuration::get_config(:DBConnection,
            'select max(checkpointendtime) from az.MappingSchemaLoadingAudit where MappingSchemaID=1859 and CurrentStatus=\'succeed\'')[0][0]
    end
    # declare table will be used in ETL for QUIX MPP Workflow
    # Notes:
    #       1.Please update projects in source SQL if needed
    set_source_connection :oracle_Bugzilla_connection
    declare_source_table %Q{select * from BUGS.bugs,BUGS.product where bugs.product_id = products.id and BUGS.CREATION_TS<=to_date(#{variables[:checkpointendtime]},'YYYY-MM-DD HH24:MI:SS')},'source'
    declare_target_table %Q{select * from dbo.ViewCRReporting where ChangeRequestID in (select changerequestid from dbo.FactChangeRequest where MappingSchemaID='859')},'target'

    #define sourceissueid field's mapping relationship
    mp target.sourceissueid do
        source.bug_id
    end

     m target.organizationunit do
        'VDU'
    end

    #define state field's mapping relationship
    m target.state do
    	if source.bug_status.gsub(/\s|"/, '').downcase=='ASSIGNED'.gsub(/\s/, '').downcase            
            'Assigned'
        elsif source.bug_status.gsub(/\s|"/, '').downcase=='REOPENED'.gsub(/\s/, '').downcase
            'Assigned'
    	elsif source.bug_status.gsub(/\s|"/, '').downcase=='CLOSED'.gsub(/\s/, '').downcase
    		'Closed'
    	elsif source.bug_status.gsub(/\s|"/, '').downcase=='NEW'.gsub(/\s/, '').downcase
    		'New'
    	elsif source.bug_status.gsub(/\s|"/, '').downcase=='VERIFIED'.gsub(/\s/, '').downcase
    		'Fix Validated'
    	elsif source.bug_status.gsub(/\s|"/, '').downcase=='RESOLVED'.gsub(/\s/, '').downcase && source.resolution.gsub(/\s|"/, '').downcase=='DUPLICATE'.gsub(/\s/, '').downcase
    		'Duplicate'
    	elsif source.bug_status.gsub(/\s|"/, '').downcase=='RESOLVED'.gsub(/\s/, '').downcase && source.resolution.gsub(/\s|"/, '').downcase=='FIXED'.gsub(/\s/, '').downcase
    		'Fix Integrated'
    	elsif source.bug_status.gsub(/\s|"/, '').downcase=='RESOLVED'.gsub(/\s/, '').downcase && source.resolution.gsub(/\s|"/, '').downcase=='LATER'.gsub(/\s/, '').downcase
    		'Deferred'
        elsif source.bug_status.gsub(/\s|"/, '').downcase=='RESOLVED'.gsub(/\s/, '').downcase && source.resolution.gsub(/\s|"/, '').downcase=='INVALID'.gsub(/\s/, '').downcase
            'Closed no Change'
        elsif source.bug_status.gsub(/\s|"/, '').downcase=='RESOLVED'.gsub(/\s/, '').downcase && source.resolution.gsub(/\s|"/, '').downcase=='WONTFIX'.gsub(/\s/, '').downcase
            'Closed no Change'
        elsif source.bug_status.gsub(/\s|"/, '').downcase=='RESOLVED'.gsub(/\s/, '').downcase && source.resolution.gsub(/\s|"/, '').downcase=='REMIND'.gsub(/\s/, '').downcase
            'Closed no Change'
        elsif source.bug_status.gsub(/\s|"/, '').downcase=='RESOLVED'.gsub(/\s/, '').downcase && source.resolution.gsub(/\s|"/, '').downcase=='CANTREPRODUCE'.gsub(/\s/, '').downcase
            'Closed no Change'
        elsif source.bug_status.gsub(/\s|"/, '').downcase=='RESOLVED'.gsub(/\s/, '').downcase && source.resolution.gsub(/\s|"/, '').downcase=='WORKSFORME'.gsub(/\s/, '').downcase
            'Closed no Change'
        elsif source.bug_status.gsub(/\s|"/, '').downcase=='RESOLVED'.gsub(/\s/, '').downcase && source.resolution.gsub(/\s|"/, '').downcase=='ABANDONED'.gsub(/\s/, '').downcase
            'Closed no Change'
        elsif source.bug_status.gsub(/\s|"/, '').downcase=='RESOLVED'.gsub(/\s/, '').downcase && source.resolution.nil?
            'Closed no Change'
        else 
            if source.bug_status.nil? && source.resolution.nil?
                ''
            elsif !source.bug_status.nil? && source.resolution.nil?
                source.bug_status
            elsif source.bug_status.nil? && !source.resolution.nil?
                source.resolution
            else
                "#{source.bug_status}/#{source.resolution}"
            end
    	end
    end
 
    #define customerencountered field's mapping relationship
    m target.customerencountered do
    	if source.cf_foundby.gsub(/\s|"/, '').downcase=='Customer (during EAP)'.gsub(/\s/, '').downcase
    		'Y'
        elsif source.cf_foundby.gsub(/\s|"/, '').downcase=='Customer (using ISV app)'.gsub(/\s/, '').downcase
            'Y'
        else
            'N'
    	end  
    end

    #define customerseverity field's mapping relationship
    m target.customerseverity do
    	if source.bug_severity.gsub(/\s|"/, '').downcase=='blocker'.gsub(/\s/, '').downcase
    		'Critical'
        elsif source.bug_severity.gsub(/\s|"/, '').downcase=='critical'.gsub(/\s/, '').downcase
            'Critical'                
    	elsif source.bug_severity.gsub(/\s|"/, '').downcase=='major'.gsub(/\s/, '').downcase
    		'Serious'
    	elsif source.bug_severity.gsub(/\s|"/, '').downcase=='minor'.gsub(/\s/, '').downcase
    		'Low'
        elsif source.bug_severity.gsub(/\s|"/, '').downcase=='trivial'.gsub(/\s/, '').downcase
            'Low'
    	elsif source.bug_severity.gsub(/\s|"/, '').downcase=='normal'.gsub(/\s/, '').downcase
    		'Medium'
        elsif source.bug_severity.nil
            ''
    	else
    		source.bug_severity
    	end
    end

    #define engineeringpriority field's mapping relationship
    m target.engineeringpriority do
    	if source.Priority.gsub(/\s|"/, '').downcase=='P1'.gsub(/\s/, '').downcase
    		'High'
    	elsif source.Priority.gsub(/\s|"/, '').downcase=='P2'.gsub(/\s/, '').downcase
    		'High'
    	elsif source.Priority.gsub(/\s|"/, '').downcase=='P3'.gsub(/\s/, '').downcase
    		'Medium'
    	elsif source.Priority.gsub(/\s|"/, '').downcase=='P4'.gsub(/\s/, '').downcase
    		'Low'
    	elsif source.Priority.gsub(/\s|"/, '').downcase=='P5'.gsub(/\s/, '').downcase
    		'None'
        elsif source.Priority.gsub(/\s|"/, '').downcase=='P6'.gsub(/\s/, '').downcase
            'None'
        elsif source.Priority.nil
            ''
		else
			source.Priority
		end
    end

    #define mustfix field's mapping relationship
    m target.mustfix do
    	if source.cf_required.gsub(/\s|"/, '').downcase=='Must Fix'.gsub(/\s/, '').downcase
    		'Y'
        elsif source.cf_required.gsub(/\s|"/, '').downcase=='Must Fix (Blocking Test)'.gsub(/\s/, '').downcase
            'Y'
        elsif source.cf_required.gsub(/\s|"/, '').downcase=='Must Fix (Documentation)'.gsub(/\s/, '').downcase
            'Y'
        elsif source.cf_required.gsub(/\s|"/, '').downcase=='Must Fix (Failing Test)'.gsub(/\s/, '').downcase
            'Y'
        else
            'N'
    	end  
    end

    #define possibilityofcustomeroccurrence field's mapping relationship
    m target.possibilityofcustomeroccurrence do
    	if source.cf_probability.gsub(/\s|"/, '').downcase=='High'.gsub(/\s/, '').downcase
    		'Likely'
        elsif source.cf_probability.gsub(/\s|"/, '').downcase=='Medium'.gsub(/\s/, '').downcase
            'Likely'                
    	elsif source.cf_probability.gsub(/\s|"/, '').downcase=='Low'.gsub(/\s/, '').downcase
    		'Unlikely'              
        elsif source.cf_probability.gsub(/\s|"/, '').downcase=='Once'.gsub(/\s/, '').downcase
            'Unlikely'
        elsif source.cf_probability.nil?
            ''
    	else
    		source.cf_probability
    	end
    end

    #define product field's mapping relationship
    m target.product do
        'StoreAll'
    end

    #define project field's mapping relationship
    m target.project do
        if source.name.nil?
            ''
        else
            source.name
        end
    end

    #define showstopper field's mapping relationship
    m target.showstopper do
    	if source.bug_severity.gsub(/\s|"/, '').downcase=='blocker '.gsub(/\s/, '').downcase
    		'Y'
        else
            'N'
    	end  
    end

    #define changerequesttype field's mapping relationship
    m target.changerequesttype do
    	if source.bug_severity.gsub(/\s|"/, '').downcase=='enhancement'.gsub(/\s/, '').downcase
	    	'Enhancement'
        else
            'Defect'
    	end  
    end
end
