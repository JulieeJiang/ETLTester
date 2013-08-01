require 'etltester'
mapping("QUIX_Component_Mapping") do


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
    declare_source_table %Q{select * from BO_QX_CR where  submitdate<= to_date('2013-07-31 21:41:51','YYYY-MM-DD HH24:MI:SS') and  BO_QX_CR.PROJECT_HIERARCHY in ('Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- Flex Power','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- Delta-DNI- Qualifications','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- UPG- Qualifications','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- UPG','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- Molex- Qualifications','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- Avocent- Qualifications','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- CIS- Qualifications','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- Avocent','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- CIS','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- Flex Power- Qualifications','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- Eaton','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- RRD- Qualifications','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- RRD','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- Amphenol','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- Jabil- Qualifications','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- Jabil','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- Delta-DNI','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- Molex','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- Eaton Qualifications','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- Active Power Qualifications','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- AlphaNetworks- Qualificatio','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- AlphaNetworks','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- Amphenol- Qualifications','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- Emerson','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- Wistron- Qualifications','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- Broadcom','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- Sanmina-SCI','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- Wistron','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- KPV','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- Active Power','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- Emulex','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- Broadcom- Qualifications','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- Qlogic- Qualifications','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- Emulex- Qualifications','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- Emerson- Qualifications','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- Lite-On- Qualifications','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- Intel- Qualifications','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- Delta- Qualifications','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- Flextronics- Qualifications','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- Foxconn- Qualifications','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- Inventec- Qualifications ISS GPE','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- Intel','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- Qlogic','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- Lite-On','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- Delta','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- Flextronics','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- Internal HP Manufacturing','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- Mitac','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- Foxconn','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->ISS- Inventec','Base Project-->HP-->TSG-->ESS-->ISS-->SharedEngService-->GPE-->Intel/QLogic Infiniband')},'source'
    declare_target_table %Q{select * from dbo.ViewCRReporting where dbo.ViewCRReporting.ChangeRequestID in (select FactChangeRequest.ChangeRequestID  from dbo.FactChangeRequest where FactChangeRequest.MappingSchemaID in (Select MappingSchemaID from az.MappingSchema where ParentMappingSchema='861'))},'target'

    #define sourceissueid field's mapping relationship
    mp target.sourceissueid do
        "#{source.internal_system_id}/#{source.system_type.upcase}"
    end

    m target.organizationunit do
        'ISS GPE '
    end

    #define state field's mapping relationship
    m target.state do
        if source.state.gsub(/\s|"/, '').downcase=='Submitted'.gsub(/\s/, '').downcase
            'New'
        elsif source.state.gsub(/\s|"/, '').downcase=='Investigation'.gsub(/\s/, '').downcase
            'Investigating'
        elsif source.state.gsub(/\s|"/, '').downcase=='Action:WIP'.gsub(/\s/, '').downcase
            'Being Fixed'
        elsif source.state.gsub(/\s|"/, '').downcase=='Action:Awaiting Completion'.gsub(/\s/, '').downcase
            'Validating Fix'
        elsif source.state.gsub(/\s|"/, '').downcase=='Completed'.gsub(/\s/, '').downcase
            'Fix Validated'
        elsif source.state.gsub(/\s|"/, '').downcase=='Closed- Duplicate Problem'.gsub(/\s/, '').downcase
            'Duplicate'
        elsif source.state.gsub(/\s|"/, '').downcase=='Closed- Not a Problem'.gsub(/\s/, '').downcase
            'Closed no Change'
        elsif source.state.gsub(/\s|"/, '').downcase=='Closed- Not in scope of Project'.gsub(/\s/, '').downcase
            'Closed no Change'
        elsif source.state.gsub(/\s|"/, '').downcase=='Closed- Other'.gsub(/\s/, '').downcase
            'Closed'
        elsif source.state.gsub(/\s|"/, '').downcase=='Closed- Outside Vendor Problem'.gsub(/\s/, '').downcase
            'Closed'
        elsif source.state.gsub(/\s|"/, '').downcase=='Closed-  Problem Not Reproducable'.gsub(/\s/, '').downcase
            'Closed no Change'
        elsif source.state.gsub(/\s|"/, '').downcase=='Closed no Change'.gsub(/\s/, '').downcase
            'Closed no Change'
        elsif source.state.gsub(/\s|"/, '').downcase=='Deferred'.gsub(/\s/, '').downcase
            'Deferred'
        elsif source.state.nil?
            ''
        else
            source.state
        end
    end

    #define foundinstep field's mapping relationship
    m target.foundinstep do
        if source.found_in_phase.gsub(/\s|"/, '').downcase=='Phase 0=Initiation '.gsub(/\s/, '').downcase
            'Initialization'
        elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Phase 1=Investigation'.gsub(/\s/, '').downcase
            'Investigation'  
        elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Phase 2=Design'.gsub(/\s/, '').downcase
            'Design'
        elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Phase 3=Implementation'.gsub(/\s/, '').downcase
            'Implementation'
        elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Phase 4.1=Alpha Test '.gsub(/\s/, '').downcase
            'Test'
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
        elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='Unknown'.gsub(/\s/, '').downcase
            'Unknown'
        elsif source.found_in_phase.gsub(/\s|"/, '').downcase=='All'.gsub(/\s/, '').downcase  
            'Unknown'
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
        elsif source.issuetype.gsub(/\s|"/, '').downcase=='Issue'.gsub(/\s/, '').downcase
            'Defect'
        elsif source.issuetype.gsub(/\s|"/, '').downcase=='Other'.gsub(/\s/, '').downcase
            'Defect'
        elsif source.issuetype.gsub(/\s|"/, '').downcase=='Planned Content'.gsub(/\s/, '').downcase
            'Enhancement'
        elsif source.issuetype.gsub(/\s|"/, '').downcase=='Release Requirement'.gsub(/\s/, '').downcase
            'Enhancement'
        elsif source.issuetype.gsub(/\s|"/, '').downcase=='SubTask'.gsub(/\s/, '').downcase
            'Enhancement'
        elsif source.issuetype.nil?
            ''                
        else
            source.issuetype
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

    #define customerencountered field's mapping relationship
    m target.customerencountered do
        case
        when source.CUSTOMER_ENCOUNTERED_FLAG.gsub(/\s|"/, '').downcase=='Y'.gsub(/\s/, '').downcase
            'Y'
        when source.CUSTOMER_ENCOUNTERED_FLAG.gsub(/\s|"/, '').downcase=='N'.gsub(/\s/, '').downcase
            'N'
        else
            ' '
        end
    end

    #define customerescalated field's mapping relationship
    m target.customerescalated do
        if source.urgency.gsub(/\s|"/, '').downcase=='5=Urgent: Customer Escalation'.gsub(/\s/, '').downcase
            'Y'
        else
            ' '
        end
    end

    #define possibilityofcustomeroccurrence field's mapping relationship
    m target.possibilityofcustomeroccurrence do
        if source.frequency.gsub(/\s|"/, '').downcase=='0=Extremely unlikely'.gsub(/\s/, '').downcase
            'Unlikely'
        elsif source.frequency.gsub(/\s|"/, '').downcase=='1=Rare'.gsub(/\s/, '').downcase
            'Unlikely'
        elsif source.frequency.gsub(/\s|"/, '').downcase=='2=Corner case'.gsub(/\s/, '').downcase
            'Unlikely'
        elsif source.frequency.gsub(/\s|"/, '').downcase=='3=Infrequent'.gsub(/\s/, '').downcase
            'Unlikely'
        elsif source.frequency.gsub(/\s|"/, '').downcase=='4=Frequent'.gsub(/\s/, '').downcase
            'Likely'
        elsif source.frequency.gsub(/\s|"/, '').downcase=='5=Very common'.gsub(/\s/, '').downcase
            'Likely'
        elsif source.frequency.nil?
            ''
        else
            source.frequency
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

    #define showstopper field's mapping relationship
    m target.showstopper do
        case 
            when source.show_stopper.gsub(/\s|"/, '').downcase=='N'.gsub(/\s/, '').downcase
                'N'
            when source.show_stopper.gsub(/\s|"/, '').downcase=='Y'.gsub(/\s/, '').downcase
                'Y'
            else
                ' '
        end
    end

    #define mustfix field's mapping relationship
    m target.mustfix do
        if source.show_stopper.gsub(/\s|"/, '').downcase=='Y'.gsub(/\s/, '').downcase
            'Y'
        else
            ' '
        end
    end

    #define engineeringpriority field's mapping relationship
    m target.engineeringpriority do
        if source.engineering_priority.gsub(/\s|"/, '').downcase=='High'.gsub(/\s/, '').downcase
            'High'
        elsif source.engineering_priority.gsub(/\s|"/, '').downcase=='Medium'.gsub(/\s/, '').downcase
            'Medium'
        elsif source.engineering_priority.gsub(/\s|"/, '').downcase=='Low'.gsub(/\s/, '').downcase
            'Low'
        elsif source.engineering_priority.nil?
            ''
        else
            source.engineering_priority  
        end
    end

    #define affectedprogramtag field's mapping relationship
    m target.affectedprogramtag do
        if source.affected_programs.gsub(/\s|"/, '').downcase=='Other'.gsub(/\s/, '').downcase 
            'Other'           
        elsif source.affected_programs.gsub(/\s|"/, '').downcase=='Unknown'.gsub(/\s/, '').downcase
            'Unknown'
        elsif source.affected_programs.nil?
            ''
        else
            source.affected_programs
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

    # define dispositionclassification  field's mapping relationship
    m target.dispositionclassification  do
        if source.disposition_classification.gsub(/\s|"/, '').downcase=='Other'.gsub(/\s/, '').downcase
            'Other'
        elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Unable to reproduce'.gsub(/\s/, '').downcase
            'Not Reproducible'
        elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='User misunderstanding'.gsub(/\s/, '').downcase
            'User Misunderstanding'
        elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Duplicate problem'.gsub(/\s/, '').downcase
            'Duplicate Problem'
        elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Not a Problem'.gsub(/\s/, '').downcase
            'Not a Problem'
        elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Not in scope of project'.gsub(/\s/, '').downcase
            'Out of Scope'
        elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Other'.gsub(/\s/, '').downcase
            'Other'
        elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Outside vendor problem'.gsub(/\s/, '').downcase
            '3rd Party Product'
        elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Problem Not Reproducible'.gsub(/\s/, '').downcase
            'Not Reproducible'
        elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Closed - Resolution Implemented'.gsub(/\s/, '').downcase
            'Resolution Implemented'
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
        elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Forward to Vendor'.gsub(/\s/, '').downcase
            'Forward to Vendor'
        elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Merged with another problem'.gsub(/\s/, '').downcase
            'Merged with Another'
        elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='No plans to implement'.gsub(/\s/, '').downcase
            'Do Not Fix'
        elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Not in Project Scope'.gsub(/\s/, '').downcase
            'Out of Scope'
        elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Other'.gsub(/\s/, '').downcase
            'Other'
        elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Question answered'.gsub(/\s/, '').downcase
            'User Misunderstanding'
        elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Referred to another project'.gsub(/\s/, '').downcase
            'Not a Problem'
        elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='See Legacy Attachment'.gsub(/\s/, '').downcase
            'Not a Problem'
        elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Unable to Reproduce'.gsub(/\s/, '').downcase
            'Not a Problem'
        elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='User Misunderstanding'.gsub(/\s/, '').downcase
            'User Misunderstanding'
        elsif source.disposition_classification.gsub(/\s|"/, '').downcase=='Workaround is solution'.gsub(/\s/, '').downcase
            'Resolution Implemented'
        elsif source.disposition_classification.nil?
            ''
        else
            source.disposition_classification
        end
    end

end
