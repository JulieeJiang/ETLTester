# encoding: utf-8
#require '../../../lib/etltester'
mapping("ALM_Mapping") do
    
    set_source_connection :oracle_ALM_connection
    
    #Using declare_source_table keyword to define source table
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
    declare_source_table %Q{select * from hpn_hpn_evpg_almig_db.bug},'source'

    source.inner_join sourcetemp, "source.bg_bug_id = sourcetemp.bg_bug_id"
    #Using declare_target_table keyword to define target table
    declare_target_table %Q{select * from dbo.ViewCRReporting where ChangeRequestID in (select changerequestid from dbo.FactChangeRequest where MappingSchemaID='1')},'target'
        
    #define primary(Or uniquer) key's mapping relationship
    mp target.sourceissueid do
        source.bg_bug_id.to_s
    end

    #define engineeringpriority field's mapping relationship            
    m target.engineeringpriority do
        if source.bg_priority=='0 - None'
            'None'
        elsif source.bg_priority=='1 - Urgent'
            'High'
        elsif source.bg_priority=='2 - High'
            'High'
        elsif source.bg_priority=='3 - Medium'
            'Medium'
        elsif source.bg_priority=='4 - Low'
            'Low'
        elsif source.bg_priority.nil?
            ''
        else
            source.bg_priority
        end
    end

    #define changerequesttype field's mapping relationship
    m target.changerequesttype do
        if source.bg_user_16=='Defect'
            'Defect'
        elsif source.bg_user_16=='Defect - Released'
            'Defect'
        elsif source.bg_user_16=='Defect - Special'
            'Defect'
        elsif source.bg_user_16=='Problem'
            'Defect'
        elsif source.bg_user_16=='Enhancement'
            'Enhancement'
        elsif source.bg_user_16=='New Feature'
            'Enhancement'
        elsif source.bg_user_16=='Special'
            'Enhancement'
        elsif source.bg_user_16.nil?
            ''
        else
            source.bg_user_16
        end
    end

    #define customerseverity field's mapping relationship
    m target.customerseverity do
        if source.bg_user_49=='1 - Urgent'
            'Critical'
        elsif source.bg_user_49=='2 - High'
            'Serious'
        elsif source.bg_user_49=='3 - Medium'
            'Medium'
        elsif source.bg_user_49=='4 - Low'
            'Low'
        elsif source.bg_user_49.nil?
            ''
        else
            source.bg_user_49
        end
    end

    #define possibilityofcustomeroccurrence field's mapping relationship
    m target.possibilityofcustomeroccurrence do
        if source.bg_user_28=='None'
            'N/A'
        elsif source.bg_user_28=='High'
            'Always'
        elsif source.bg_user_28=='Medium'
            'Very Likely'
        elsif source.bg_user_28=='Low'
            'Likely'
        elsif source.bg_user_28.nil?
            ''
        else
            source.bg_user_28
        end
    end

    #define customerencountered field's mapping relationship
    m target.customerencountered do
        case
            when source.BG_USER_TEMPLATE_02=='Y'
                'Y'
            when source.BG_USER_TEMPLATE_02=='N'
                'N'
            else
                ' '
        end
    end

    #define dispositionclassification field's mapping relationship
    m target.dispositionclassification do
        if source.bg_user_07=='As Designed'
            'User Misunderstanding'
        elsif source.bg_user_07=='Deferred'
            'Deferred'
        elsif source.bg_user_07=='Documentation Issue'
            'Documentation Change'
        elsif source.bg_user_07=='Duplicate'
            'Duplicate Problem'
        elsif source.bg_user_07=='External Issue'
            '3rd Party Product'
        elsif source.bg_user_07=='Fixed'
            'Resolution Implemented'
        elsif source.bg_user_07=='Not a Defect'
            'Not a Problem'
        elsif source.bg_user_07=='Not Reproducible'
            'Not Reproducible'
        elsif source.bg_user_07=='Will Never Fix'
            'Do Not Fix'
        elsif source.bg_user_07.nil?
            ''
        else
            source.bg_user_07
        end
    end

    #define qablocker field's mapping relationship
    m target.qablocker do 
        if source.bg_user_21=='STC Blocker'
            'Y'
        else
            'N'
        end
    end

    #define project field's mapping relationship
    m target.project do 
        if source.bg_user_15.nil?
            ''
        else
            source.bg_user_15
        end        
    end

    #define product field's mapping relationship
    m target.product do
        if source.bg_user_10.nil?
            ''
        else
            source.bg_user_10
        end     
    end

    m target.Organizationunit do
        'HPN'
    end

    m target.foundinstep do
        if source.BG_USER_05=='ASIC - Backend Rule Checks'
            'Test'
        elsif source.BG_USER_05=='ASIC - Equivalence Check'
            'Test'
        elsif source.BG_USER_05=='ASIC - Formal CDC'
            'Test'
        elsif source.BG_USER_05=='ASIC - Gate Sims - Incoming'
            'Test'
        elsif source.BG_USER_05=='ASIC - Gate Sims - Outcoming'
            'Test'
        elsif source.BG_USER_05=='ASIC - Linter'
            'Test'
        elsif source.BG_USER_05=='ASIC - Mutation Analysis (Certitude)'
            'Test'
        elsif source.BG_USER_05=='ASIC - PostSil CPU'
            'Test'
        elsif source.BG_USER_05=='ASIC - PostSil FE'
            'Test'
        elsif source.BG_USER_05=='ASIC - PostSil HA'
            'Test'
        elsif source.BG_USER_05=='ASIC - PostSil MAC'
            'Test'
        elsif source.BG_USER_05=='ASIC - PostSil Other'
            'Test'
        elsif source.BG_USER_05=='ASIC - PostSil Performance'
            'Test'
        elsif source.BG_USER_05=='ASIC - PreSil Arch Sim'
            'Test'
        elsif source.BG_USER_05=='ASIC - PreSil Block Regression'
            'Test'
        elsif source.BG_USER_05=='ASIC - PreSil Block Sim'
            'Test'
        elsif source.BG_USER_05=='ASIC - PreSil Cluster Regression'
            'Test'
        elsif source.BG_USER_05=='ASIC - PreSil Formal Property Verif'
            'Test'
        elsif source.BG_USER_05=='ASIC - PreSil Functionality Test'
            'Test'
        elsif source.BG_USER_05=='ASIC - PreSil Other'
            'Test'
        elsif source.BG_USER_05=='ASIC - PreSil System Regression'
            'Test'
        elsif source.BG_USER_05=='ASIC - PreSil System Sim'
            'Test'
        elsif source.BG_USER_05=='ASIC - SVA'
            'Test'
        elsif source.BG_USER_05=='ASIC - Synthesis'
            'Test'
        elsif source.BG_USER_05=='ASIC - Timing Analysis (PrimeTime)'
            'Test'
        elsif source.BG_USER_05=='Automation CIT'
            'Test'
        elsif source.BG_USER_05=='Automation Development'
            'Test'
        elsif source.BG_USER_05=='Automation Production Testing'
            'Test'
        elsif source.BG_USER_05=='Automation Validation'
            'Test'
        elsif source.BG_USER_05=='Customer - Beta Test'
            'Test'
        elsif source.BG_USER_05=='Customer - Normal Usage'
            'Post Release'
        elsif source.BG_USER_05=='Customer - Support Normal Usage'
            'Post Release'
        elsif source.BG_USER_05=='HW - Bring-Up'
            'Test'
        elsif source.BG_USER_05=='HW - Climatics Test'
            'Test'
        elsif source.BG_USER_05=='HW - DVT Test'
            'Test'
        elsif source.BG_USER_05=='HW - General Test'
            'Test'
        elsif source.BG_USER_05=='HW - Margin Test'
            'Test'
        elsif source.BG_USER_05=='HW - Mechanical Test'
            'Test'
        elsif source.BG_USER_05=='HW - Parametric Test'
            'Test'
        elsif source.BG_USER_05=='HW - Performance Test'
            'Test'
        elsif source.BG_USER_05=='HW - Regulatory Test'
            'Test'
        elsif source.BG_USER_05=='HW - Shock Test'
            'Test'
        elsif source.BG_USER_05=='HW - Thermal Test'
            'Test'
        elsif source.BG_USER_05=='HW - Transceiver Qualification'
            'Test'
        elsif source.BG_USER_05=='HW - Vibration Test'
            'Test'
        elsif source.BG_USER_05=='Lab - Code Review'
            'Design'
        elsif source.BG_USER_05=='Lab - Design Review'
            'Design'
        elsif source.BG_USER_05=='Lab - Enhancement'
            'Investigation'
        elsif source.BG_USER_05=='Lab - Internal Partner Testing'
            'Test'
        elsif source.BG_USER_05=='Lab - Investigation Review'
            'Investigation'
        elsif source.BG_USER_05=='Lab - Normal Usage'
            'Implementation'
        elsif source.BG_USER_05=='Lab - Requirements Review'
            'Design'
        elsif source.BG_USER_05=='MFG - General'
            'Implementation'
        elsif source.BG_USER_05=='MFG - Lower Level Build'
            'Implementation'
        elsif source.BG_USER_05=='MFG - Process Qual'
            'Implementation'
        elsif source.BG_USER_05=='MFG - Upper Level Build'
            'Implementation'
        elsif source.BG_USER_05=='STC - Automated Test'
            'Test'
        elsif source.BG_USER_05=='STC - Conformance'
            'Test'
        elsif source.BG_USER_05=='STC - Functional/Feature Test'
            'Test'
        elsif source.BG_USER_05=='STC - HW Performance and Stress'
            'Test'
        elsif source.BG_USER_05=='STC - Performance Test'
            'Test'
        elsif source.BG_USER_05=='STC - Readiness Test'
            'Test'
        elsif source.BG_USER_05=='STC - Scalability Test'
            'Test'
        elsif source.BG_USER_05=='STC - Security Test'
            'Test'
        elsif source.BG_USER_05=='STC - Solutions Test'
            'Test'
        elsif source.BG_USER_05=='STC - SW Stress Test'
            'Test'
        elsif source.BG_USER_05=='STC - Third Party Test'
            'Test'
        elsif source.BG_USER_05=='SW - Automated Test'
            'Test'
        elsif source.BG_USER_05=='SW - Component Test'
            'Test'
        elsif source.BG_USER_05=='SW - Conformance'
            'Test'
        elsif source.BG_USER_05=='SW - Functional/Feature Test'
            'Test'
        elsif source.BG_USER_05=='SW - Integration Test'
            'Test'
        elsif source.BG_USER_05=='SW - Internal Early Exposure'
            'Test'
        elsif source.BG_USER_05=='SW - Partner Integration'
            'Test'
        elsif source.BG_USER_05=='SW - Partner Test'
            'Test'
        elsif source.BG_USER_05=='SW - Performance Test'
            'Test'
        elsif source.BG_USER_05=='SW - Static Analysis'
            'Test'
        elsif source.BG_USER_05=='SW - Unit Test'
            'Test'
        elsif source.BG_USER_05.nil?
            ''
        else 
            source.BG_USER_05
        end
    end

    #puts @source_sql_generator.generate_sql
end
