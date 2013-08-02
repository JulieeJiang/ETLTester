require 'etltester'

mapping('Demo') do

    set_source_connection :oracle_ALM_connection
    
    declare_dynamic_source_table :sourcetemp do
        check_point_end_time = ETLTester::Util::DBConnection::get_data_from_db(ETLTester::Util::Configuration::get_config(:DBConnection),
            "select max(checkpointendtime) from az.MappingSchemaLoadingAudit where MappingSchemaID=1 and CurrentStatus='succeed'")[0][0].strftime("%Y-%m-%d %H:%M:%S")
            %Q{select distinct bg_bug_id from hpn_hpn_evpg_almig_db.bug,hpn_hpn_evpg_almig_db.audit_log 
                        where bug.bg_user_16 <> 'Task' and bug.bg_user_16 <> 'VOID Record' and bug.bg_user_49 <> '0 - None' 
                        and to_char(bg_bug_id)=au_entity_id and au_time<=to_date('#{check_point_end_time}','YYYY-MM-DD HH24:MI:SS') 
                        and au_action <> 'DELETE'
                        and au_entity_type = 'BUG'
                        and au_time > 
                        (
                        select max(au_time) 
                        from hpn_hpn_evpg_almig_db.audit_log aa 
                        where hpn_hpn_evpg_almig_db.audit_log.au_entity_id = aa.au_entity_id and aa.au_action = 'DELETE' 
                        and aa.au_entity_type = 'BUG')
                    }
    end
    
    declare_source_table %Q{select * from hpn_hpn_evpg_almig_db.bug},:bug

    bug.inner_join sourcetemp, "bug.bg_bug_id = sourcetemp.bg_bug_id"
    
    declare_target_table %Q{select * from dbo.ViewCRReporting where ChangeRequestID in (select changerequestid from dbo.FactChangeRequest where MappingSchemaID='1')},:target
        
    mp target.sourceissueid do
        bug.bg_bug_id.to_s
    end

    define_variable :mapping_doc do # Read data from Excel
        excel_path = (ETLTester::Util::Configuration::get_config(:Project_Home) + "/reference/2013 07 30_HPN Workflow_Mapping to GF_2013_v4.xlsx").gsub "/", "\\"
        parse_excel(excel_path, 2)
    end 

    define_variable :engineering_priority_mapping do
        map = {}
        variables[:mapping_doc].select {|r| r["ESSN Column Name"] == 'EngineeringPriority'}.each {|r| map[r['SRC Value']] = r['ESSN Value']}
        map
    end

    m target.engineeringpriority do
        if variable[:engineering_priority_mapping][bug.bg_priority].nil?
            bug.bg_priority.nil? ? '' : bug.bg_priority
        else
            variable[:engineering_priority_mapping][bug.bg_priority]    
        end
    end

    define_variable :change_request_type do
        map = {}
        variables[:mapping_doc].select {|r| r["ESSN Column Name"] == 'ChangeRequestType'}.each {|r| map[r['SRC Value']] = r['ESSN Value'] if !r['ESSN Value'].nil?}
        map
    end

    m target.changerequesttype do
        if variable[:change_request_type][bug.bg_user_16].nil?
            bug.bg_user_16.nil? ? '' : bug.bg_user_16
        else
            variable[:change_request_type][bug.bg_user_16]
        end
    end

    define_variable :customer_severity do
        map = {}
        variables[:mapping_doc].select {|r| r["ESSN Column Name"] == 'CustomerSeverity'}.each {|r| map[r['SRC Value']] = r['ESSN Value'] if !r['ESSN Value'].nil?}
        map
    end

    m target.customerseverity do
        if variable[:customer_severity][bug.bg_user_49].nil?
            bug.bg_user_49.nil? ? '' : bug.bg_user_49
        else
            variable[:customer_severity][bug.bg_user_49]
        end
    end

    define_variable :probablility_of_customer_occurrence do
        map = {}
        variables[:mapping_doc].select {|r| r["ESSN Column Name"] == 'ProbablilityofCustomerOccurrence'}.each {|r| map[r['SRC Value']] = r['Notes']}
        map        
    end

    m target.possibilityofcustomeroccurrence do
        if variable[:probablility_of_customer_occurrence][bug.bg_user_28].nil?
            bug.bg_user_28.nil? ? '' : bug.bg_user_28
        else
            variable[:probablility_of_customer_occurrence][bug.bg_user_28]
        end
    end

    m target.customerencountered do
        case
            when bug.bg_user_template_02 == 'Y'
                'Y'
            when bug.bg_user_template_02 == 'N'
                'N'
            else
                ' '
        end
    end

    define_variable :state do
        map = {}
        variables[:mapping_doc].select {|r| r["ESSN Column Name"] == 'State'}.each {|r| map[r['SRC Value']] = r['ESSN Value'] if r['SRC Label'].split('/').size == 2}
        map        
    end

    m target.state do
        bug_field = "#{bug.bg_status} / #{bug.bg_user_03.nil? ? 'null' : bug.bg_user_03}"
        bug.bg_user_07 # declare column.
        if variables[:state][bug_field].nil?
            if bug.bg_user_07 != 'Fixed'
                if bug_field == 'Closed / Closed' or bug_field == 'Closed / null'
                    'Closed no Change'
                else
                    'No mapping rule!'
                end
            else
                if bug_field == 'Closed / null'
                    'Closed no Change'
                else
                    'No mapping rule!'
                end
            end
        else
            variables[:state][bug_field]
        end
    end

    # Get the mapping values from excel.
    define_variable :found_in_step do
        map = {}
        variables[:mapping_doc].select {|r| r["ESSN Column Name"] == 'FoundInStep'}.each {|r| map[r['SRC Value']] = r['ESSN Value']}
        map        
    end

    m target.foundinstep do
        if variable[:found_in_step][bug.bg_user_05].nil? 
            bug.bg_user_05.nil? ? '' : bug.bg_user_05
        else
            variable[:found_in_step][bug.bg_user_05]
        end        
    end

end