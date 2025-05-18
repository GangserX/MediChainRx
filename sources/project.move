module HealthCare::PatientTreatment {
    use aptos_framework::signer;
    use std::string::String;
    use aptos_framework::timestamp;
    use std::vector;

    /// Error codes
    const E_NOT_AUTHORIZED: u64 = 1;
    const E_TREATMENT_NOT_FOUND: u64 = 2;
    const E_CONSENT_REQUIRED: u64 = 3;
    const E_ALREADY_COMPLETED: u64 = 4;
    
    /// Struct representing a patient's treatment plan
    struct TreatmentPlan has store {
        doctor_address: address,     // Address of the doctor who created the plan
        patient_address: address,    // Address of the patient
        treatment_description: String, // Description of the treatment
        created_at: u64,             // Timestamp when the treatment was created
        last_updated: u64,           // Timestamp of last update
        is_completed: bool,          // Indicates if treatment is completed
        patient_consent: bool,       // Patient consent status
        medications: vector<Medication> // List of prescribed medications
    }
    
    /// Struct representing a medication prescription
    struct Medication has store, drop {
        name: String,
        dosage: String,
        frequency: String,
        start_date: u64,
        end_date: u64
    }
    
    /// Collection to store all treatment plans created by a doctor
    struct DoctorTreatments has key {
        treatments: vector<TreatmentPlan>
    }
    
    /// Collection to store all treatment plans for a patient
    struct PatientTreatments has key {
        treatments: vector<address>  // Stores doctor addresses who created treatments for this patient
    }
    
    /// Function for doctors to create a new treatment plan for a patient
    public entry fun create_treatment_plan(
        doctor: &signer,
        patient_addr: address,
        description: String
    ) acquires DoctorTreatments, PatientTreatments {
        let doctor_addr = signer::address_of(doctor);
        
        let treatment = TreatmentPlan {
            doctor_address: doctor_addr,
            patient_address: patient_addr,
            treatment_description: description,
            created_at: timestamp::now_seconds(),
            last_updated: timestamp::now_seconds(),
            is_completed: false,
            patient_consent: false,
            medications: vector::empty()
        };
        
        // If doctor doesn't have a treatment collection yet, create one
        if (!exists<DoctorTreatments>(doctor_addr)) {
            move_to(doctor, DoctorTreatments { treatments: vector::empty() });
        };
        
        // Add the new treatment to the doctor's collection
        let treatments = &mut borrow_global_mut<DoctorTreatments>(doctor_addr).treatments;
        vector::push_back(treatments, treatment);
        
        // If patient doesn't have a treatments collection yet, create one
        if (!exists<PatientTreatments>(patient_addr)) {
            // Note: This is a simplified approach. In production, you would need
            // a different mechanism to initialize the patient's resource
            if (signer::address_of(doctor) == patient_addr) {
                move_to(doctor, PatientTreatments { treatments: vector::empty() });
            };
        };
        
        // If patient has a treatments collection, add this doctor to their list
        if (exists<PatientTreatments>(patient_addr)) {
            let patient_treatments = &mut borrow_global_mut<PatientTreatments>(patient_addr).treatments;
            vector::push_back(patient_treatments, doctor_addr);
        };
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
                // Check if patient has given consent
                assert!(treatment.patient_consent, E_CONSENT_REQUIRED);
                // Check if treatment is not already completed
                assert!(!treatment.is_completed, E_ALREADY_COMPLETED);
                
                treatment.treatment_description = new_description;
                treatment.last_updated = timestamp::now_seconds();
                found = true;
                break
            };
            i = i + 1;
        };
        
        assert!(found, E_TREATMENT_NOT_FOUND);
    }
    
    /// Function for patients to provide consent for their treatment plan
    public entry fun provide_consent(
        patient: &signer,
        doctor_addr: address
    ) acquires DoctorTreatments {
        let patient_addr = signer::address_of(patient);
        
        // Verify the doctor has treatment plans
        assert!(exists<DoctorTreatments>(doctor_addr), E_TREATMENT_NOT_FOUND);
        
        // Access the doctor's treatments
        let treatments = &mut borrow_global_mut<DoctorTreatments>(doctor_addr).treatments;
        
        // Find and update consent for the patient's treatment plan
        let len = vector::length(treatments);
        let i = 0;
        let found = false;
        
        while (i < len) {
            let treatment = vector::borrow_mut(treatments, i);
            if (treatment.patient_address == patient_addr) {
                treatment.patient_consent = true;
                treatment.last_updated = timestamp::now_seconds();
                found = true;
                break
            };
            i = i + 1;
        };
        
        assert!(found, E_TREATMENT_NOT_FOUND);
    }
    
    /// Function to mark a treatment as completed
    public entry fun complete_treatment(
        doctor: &signer,
        patient_addr: address
    ) acquires DoctorTreatments {
        let doctor_addr = signer::address_of(doctor);
        
        // Verify the doctor has treatment plans
        assert!(exists<DoctorTreatments>(doctor_addr), E_TREATMENT_NOT_FOUND);
        
        // Access the doctor's treatments
        let treatments = &mut borrow_global_mut<DoctorTreatments>(doctor_addr).treatments;
        
        // Find and mark the treatment as completed
        let len = vector::length(treatments);
        let i = 0;
        let found = false;
        
        while (i < len) {
            let treatment = vector::borrow_mut(treatments, i);
            if (treatment.patient_address == patient_addr) {
                // Check if patient has given consent
                assert!(treatment.patient_consent, E_CONSENT_REQUIRED);
                
                treatment.is_completed = true;
                treatment.last_updated = timestamp::now_seconds();
                found = true;
                break
            };
            i = i + 1;
        };
        
        assert!(found, E_TREATMENT_NOT_FOUND);
    }
    
    /// Function to add medication to a treatment plan
    public entry fun add_medication(
        doctor: &signer,
        patient_addr: address,
        med_name: String,
        med_dosage: String,
        med_frequency: String,
        med_duration_days: u64
    ) acquires DoctorTreatments {
        let doctor_addr = signer::address_of(doctor);
        
        // Verify the doctor has treatment plans
        assert!(exists<DoctorTreatments>(doctor_addr), E_TREATMENT_NOT_FOUND);
        
        // Access the doctor's treatments
        let treatments = &mut borrow_global_mut<DoctorTreatments>(doctor_addr).treatments;
        
        // Find the treatment to add medication to
        let len = vector::length(treatments);
        let i = 0;
        let found = false;
        
        let now = timestamp::now_seconds();
        let end_date = now + (med_duration_days * 86400); // Convert days to seconds
        
        while (i < len) {
            let treatment = vector::borrow_mut(treatments, i);
            if (treatment.patient_address == patient_addr) {
                // Check if patient has given consent
                assert!(treatment.patient_consent, E_CONSENT_REQUIRED);
                // Check if treatment is not already completed
                assert!(!treatment.is_completed, E_ALREADY_COMPLETED);
                
                // Create and add the medication
                let medication = Medication {
                    name: med_name,
                    dosage: med_dosage,
                    frequency: med_frequency,
                    start_date: now,
                    end_date
                };
                
                vector::push_back(&mut treatment.medications, medication);
                treatment.last_updated = now;
                found = true;
                break
            };
            i = i + 1;
        };
        
        assert!(found, E_TREATMENT_NOT_FOUND);
    }
    
    /// Function to get details of a treatment (view function)
    #[view]
    public fun get_treatment_details(
        doctor_addr: address,
        patient_addr: address
    ): (String, u64, bool, u64) acquires DoctorTreatments {
        // Verify the doctor has treatment plans
        assert!(exists<DoctorTreatments>(doctor_addr), E_TREATMENT_NOT_FOUND);
        
        // Access the doctor's treatments
        let treatments = &borrow_global<DoctorTreatments>(doctor_addr).treatments;
        
        // Find the treatment for the specified patient
        let len = vector::length(treatments);
        let i = 0;
        
        while (i < len) {
            let treatment = vector::borrow(treatments, i);
            if (treatment.patient_address == patient_addr) {
                return (
                    treatment.treatment_description,
                    treatment.created_at,
                    treatment.is_completed,
                    vector::length(&treatment.medications)
                )
            };
            i = i + 1;
        };
        
        abort E_TREATMENT_NOT_FOUND
    }
}