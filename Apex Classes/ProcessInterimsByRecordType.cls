//Class that can be invoked in code or via ETL job to kick off the UCI Interim processing jobs.
//Invoking call example: ProcessInterimsByRecordType.processInterims('ODS_Student_BioDemo', 'a1K8G000000QQKxUAO', false, 50);
public class ProcessInterimsByRecordType {
    //Primary method for invoking interim processing. Uses parameters from the invoking call to dedupe and process interims based on passed RecordTypeName and Matching Rule
    //Params:
    //  InterimRecordTypeApiName: The API (Developer) Record Type Name of the Interims that the job should process. Not the label, this should be of the form XXX_XXX (eg. ODS_Student_BioDemo)
    //  MatchingRuleSFID: The Salesforce ID of the matching rule that should be used for deduping. This can be retreived from the Matching Rule record in the UI/UX interface
    //  IsManagedRecordType: Boolean value indicating if the Record Type of the Interim is managed. If it is managed (built and ootb by UCI), this flag will include the proper namespace for the record type
    //  BatchSize: Integer value to specify batch size of the running job. Recommended standard value is 50, but depending on load type, amount of data, potential for record lock, etc, you may wish to drop this
    //             down to 10 or 20 or even single digits in extreeme cases. 
    public static void processInterims(String InterimRecordTypeApiName, String MatchingRuleSFID, Boolean IsManagedRecordType, Integer BatchSize) {
        //Init empty Map var to store variable definitions to be passed to the UCI job
        Map<String, Object> additionalVariables = new Map<String, Object>();
        //Set the Inteirm Record Type, from the parameters
        additionalVariables.put('customizedLogic_interimRecordTypeDeveloperName', InterimRecordTypeApiName);
        //Add UCI's Managed Package prefix if this is a managed package record type, using parameter boolean
        if(IsManagedRecordType) additionalVariables.put('customizedLogic_interimRecordTypeNamespace', 'ucinn_ascendv2');
        //Set the Matching Rule from the parameters
        additionalVariables.put('matchingRuleId', MatchingRuleSFID);
        //Set the Duplicate Checked field name. For anythign but interim-to-interim, this will always be hard-coded to the value below.
        //Should you ever expand interim use to more complex use cases requiring interim-to-interim matching, this may need to be parameterized in the future
        additionalVariables.put('duplicateCheckedFieldAPIName', 'Possible_Duplicate_Checked__c');
        //Sets the flag to execute the dedupe job. Hard-coding to true as there are very few cases where you do not want to dedupe.
        additionalVariables.put('executeInterimToContactDedupe', true);
        //Set batch size for the jobs, using the passed parameter
        additionalVariables.put('ascend_DEDUPE_FindDuplicateBatchSize', BatchSize);
        additionalVariables.put('ascend_DEDUPE_ProcessInterimNewBatchSize', BatchSize);
        additionalVariables.put('ascend_DEDUPE_ProcessPendingBatchSize', BatchSize);
        additionalVariables.put('ascend_DEDUPE_ProcessInProgressBatchSize', BatchSize);
        //Set the process interim flag, which tells the job to process the interims in batch after the dedupe process is complete. Hard-coding to true, but can be parameterized in the future if desired
        additionalVariables.put('executeInterimProcessing', true);
        //Invoke the UCI batch interim processing job; this will kick off four batch jobs in succession using UCI logic and the logic defined above
        ucinn_ascendv2.ascend_UTIL_RunBatch.processInterimsByRecordType(additionalVariables);
    }
}