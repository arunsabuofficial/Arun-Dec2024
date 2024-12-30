public class CandidateSummaryListController {
    
    public class CandidateDataWrapper {
        // Wrapper class properties
        public String TopSkillWithRating { get; set; }
        public String EvaluationStatus { get; set; }
        public Id TaskLastWorkedon { get; set; }
        public candidate__c CandidateRecord { get; set; }

        // Constructor to initialize the wrapper object
        public CandidateDataWrapper(String TopSkillWithRating, Id TaskLastWorkedon, String EvaluationStatus,candidate__c CandidateRecord) {
            this.TopSkillWithRating = TopSkillWithRating;
            this.TaskLastWorkedon = TaskLastWorkedon;
            this.EvaluationStatus = EvaluationStatus;
             this.CandidateRecord = CandidateRecord;       
        }
    }

    public List<CandidateDataWrapper> candidateDataWrapperList { get; set; }

    public CandidateSummaryListController() {
        candidateDataWrapperList = new List<CandidateDataWrapper>();  // Initialize the list

        List<Candidate__c> candList = [SELECT Id, Full_Name__c, LinkedIn_URL__c, Trailblazer_URL__c, Overall_Rating__c, Total_Certifications__c, Top_Skills_s_with_Rating__c, Total_Evaluated_Days__c,
                                            (SELECT Id, name,Skill__r.name, Expertise__c FROM Candidate_Skill_Junction__r ORDER BY Expertise__c DESC), 
                                            (SELECT Id, Evaluation_Task__c, Submission_Date__c FROM Daily_Status__r ORDER BY Submission_Date__c DESC) 
                                        FROM Candidate__c];

        for (Candidate__c cand : candList) {
            String skillWithRating = ''; 
            Decimal maxExpertise = 0;

            // Check if Candidate_Skill_Junction__r is not null
            if (cand.Candidate_Skill_Junction__r != null) {
                for (Candidate_Skill_Junction__c skill : cand.Candidate_Skill_Junction__r) {
                    // Null checks for Expertise__c and Name
                    if (skill.Expertise__c != null && skill.Skill__r.name != null) {
                        if (maxExpertise == 0) {
                            maxExpertise = skill.Expertise__c;
                            skillWithRating += skill.Skill__r.name + ' - ' + skill.Expertise__c;
                        }
                        else if (skill.Expertise__c == maxExpertise) {
                            skillWithRating += ', ' + skill.Skill__r.name + ' - ' + skill.Expertise__c;
                        }
                    }
                }
            }

            // Ensure task list is not null before accessing
            Id TaskLastWorkedon = null;
            if (cand.Daily_Status__r != null && !cand.Daily_Status__r.isEmpty()) {
                TaskLastWorkedon = cand.Daily_Status__r[0].Evaluation_Task__c;
            }

            
            String EvaluationStatus = 'Not Evaluated';
            if(!cand.Daily_Status__r.isempty()){
            if(cand.Daily_Status__r[0].Submission_Date__c==(System.today()-1)){

                EvaluationStatus = 'Under Evaluation';
            }
            else {
                 EvaluationStatus = 'Completed';
            }
        }
            // Create and add the wrapper data
            CandidateDataWrapper candData = new CandidateDataWrapper(skillWithRating, TaskLastWorkedon, EvaluationStatus,cand);
            candidateDataWrapperList.add(candData);
        }
    }
}