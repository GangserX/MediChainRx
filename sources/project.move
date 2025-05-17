module HealthCare::PatientTreatment {
    use aptos_framework::signer;
    use std::string::String;
    use aptos_framework::timestamp;
    use std::vector;

    /// Error codes
    const E_NOT_AUTHORIZED: u64 = 1;
    const E_TREATMENT_NOT_FOUND: u64 = 2;
    
    /// Struct representing a patient's treatment plan
    struct TreatmentPlan has store {
        doctor_address: address,     // Address of the doctor who created the plan
        patient_address: address,    // Address of the patient
        treatment_description: String, // Description of the treatment
        created_at: u64,             // Timestamp when the treatment was created
        last_updated: u64            // Timestamp of last update
    }
    
    /// Collection to store all treatment plans created by a doctor
    struct DoctorTreatments has key {
        treatments: vector<TreatmentPlan>
    }
    
    /// Function for doctors to create a new treatment plan for a patient
    public entry fun create_treatment_plan(
        doctor: &signer,
        patient_addr: address,
        description: String
    ) acquires DoctorTreatments {
        let doctor_addr = signer::address_of(doctor);
        
        let treatment = TreatmentPlan {
            doctor_address: doctor_addr,
            patient_address: patient_addr,
            treatment_description: description,
            created_at: timestamp::now_seconds(),
            last_updated: timestamp::now_seconds()
        };
        
        // If doctor doesn't have a treatment collection yet, create one
        if (!exists<DoctorTreatments>(doctor_addr)) {
            move_to(doctor, DoctorTreatments { treatments: vector::empty() });
        };
        
        // Add the new treatment to the doctor's collection
        let treatments = &mut borrow_global_mut<DoctorTreatments>(doctor_addr).treatments;
        vector::push_back(treatments, treatment);
    }
    
    /// Function to update an existing treatment plan for a specific patient
    public entry fun update_treatment(
        doctor: &signer,
        patient_addr: address,
        new_description: String
    ) acquires DoctorTreatments {
        let doctor_addr = signer::address_of(doctor);
        
        // Verify the doctor has treatment plans
        assert!(exists<DoctorTreatments>(doctor_addr), E_TREATMENT_NOT_FOUND);
        
        // Access the doctor's treatments
        let treatments = &mut borrow_global_mut<DoctorTreatments>(doctor_addr).treatments;
        
        // Find and update the treatment for the specified patient
        let len = vector::length(treatments);
        let i = 0;
        let found = false;
        
        while (i < len) {
            let treatment = vector::borrow_mut(treatments, i);
            if (treatment.patient_address == patient_addr) {
                treatment.treatment_description = new_description;
                treatment.last_updated = timestamp::now_seconds();
                found = true;
                break
            };
            i = i + 1;
        };
        
        assert!(found, E_TREATMENT_NOT_FOUND);
    }
}