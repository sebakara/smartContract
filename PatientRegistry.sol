// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PatientRegistry {
    // Struct to represent a treatment
    struct Treatment {
        string description;
        uint256 cost;
        uint256 timestamp;
        address doctorAddress;
    }

    // Struct to represent a doctor
    struct Doctor {
        string name;
        bool isRegistered;
    }

    // Struct to represent a patient
    struct Patient {
        string name;
        uint256 age;
        address walletAddress;
        bool isRegistered;
        Treatment[] treatments;
    }

    // Mapping to store doctors
    mapping(address => Doctor) public doctors;

    // Mapping to store patients
    mapping(address => Patient) public patients;

    // Event to notify when a new patient is registered
    event PatientRegistered(address indexed patientAddress, string name, uint256 age);

    // Event to notify when a treatment is recorded
    event TreatmentRecorded(address indexed patientAddress, address indexed doctorAddress, string description, uint256 cost, uint256 timestamp);

    // Modifier to ensure that only registered patients can access certain functions
    modifier onlyRegisteredPatients() {
        require(patients[msg.sender].isRegistered, "Patient not registered");
        _;
    }

    // Modifier to ensure that only registered doctors can access certain functions
    modifier onlyRegisteredDoctors() {
        require(doctors[msg.sender].isRegistered, "Access denied!");
        _;
    }

    // Function to register a new patient
    function registerPatient(string memory _name, uint256 _age) external {
        require(!patients[msg.sender].isRegistered, "Patient already registered");
        
        Patient storage newPatient = patients[msg.sender];
        newPatient.name = _name;
        newPatient.age = _age;
        newPatient.walletAddress = msg.sender;
        newPatient.isRegistered = true;

        emit PatientRegistered(msg.sender, _name, _age);
    }

    // Function to register a new doctor
    function registerDoctor(string memory _name) external {
        require(!doctors[msg.sender].isRegistered, "Doctor already registered");

        Doctor storage newDoctor = doctors[msg.sender];
        newDoctor.name = _name;
        newDoctor.isRegistered = true;
    }

    // Function to record a treatment for a patient
    function recordTreatment(address _patientAddress, string memory _description, uint256 _cost) external onlyRegisteredDoctors {
        Treatment memory newTreatment = Treatment({
            description: _description,
            cost: _cost,
            timestamp: block.timestamp,
            doctorAddress: msg.sender
        });

        patients[_patientAddress].treatments.push(newTreatment);

        emit TreatmentRecorded(_patientAddress, msg.sender, _description, _cost, block.timestamp);
    }

    // Function to get patient details including treatments
    function getPatientDetails() external view onlyRegisteredPatients returns (string memory, uint256, address, Treatment[] memory) {
        Patient storage patient = patients[msg.sender];
        return (patient.name, patient.age, patient.walletAddress, patient.treatments);
    }

    // Function to get patient records for a single patient
    function getPatientRecords(address _patientAddress) external view returns (string memory, uint256, address, Treatment[] memory) {
        require(
            msg.sender == _patientAddress || doctors[msg.sender].isRegistered,
            "Caller is not the patient or a registered doctor"
        );

        Patient storage patient = patients[_patientAddress];
        return (patient.name, patient.age, patient.walletAddress, patient.treatments);
    }
}
