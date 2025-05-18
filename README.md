# HealthCare: Blockchain-Based Patient Treatment Management

## 🏥 Overview

HealthCare is a decentralized application built on the Aptos blockchain that enables secure, transparent, and immutable management of patient treatment plans. Leveraging blockchain technology's inherent security features, this system creates a trustworthy environment for managing sensitive medical information between healthcare providers and patients.

## ⚡ Key Features

- **Secure Treatment Plans**: Doctors can create and manage treatment plans for their patients with blockchain-level security
- **Immutable Record Keeping**: All treatment history is permanently recorded on the blockchain, ensuring data integrity
- **Permissioned Access**: Only authorized doctors can create and update treatment records
- **Transparent History**: Complete treatment history and updates are visible and verifiable
- **Decentralized Storage**: No central point of failure for critical medical data

## 📋 Technical Architecture

The system is built using:
- **Aptos Blockchain**: Fast, secure Layer 1 blockchain with high throughput
- **Move Language**: Secure programming language designed for smart contract development
- **Resource-Oriented Design**: Leverages Move's resource model for secure data management

## 📝 Smart Contract Structure

- **TreatmentPlan**: A resource representing a single patient's treatment plan
- **DoctorTreatments**: A collection resource that stores all treatment plans created by a doctor
- **Functions**:
  - `create_treatment_plan`: Creates a new treatment plan for a patient
  - `update_treatment`: Updates an existing treatment plan with new information

## 🚀 Getting Started

### Prerequisites

- [Aptos CLI](https://aptos.dev/tools/aptos-cli/)
- [Move Compiler](https://aptos.dev/tools/aptos-cli/use-cli/cli-move/)
- An Aptos account with funds for gas

### Installation

1. Clone this repository:
```bash
git clone https://github.com/yourusername/healthcare-aptos
cd healthcare-aptos
```

2. Compile the Move modules:
```bash
aptos move compile
```

3. Publish the module to your account:
```bash
aptos move publish
```

## 💻 Usage Examples

### Creating a Treatment Plan

```bash
aptos move run --function-id $ACCOUNT_ADDRESS::PatientTreatment::create_treatment_plan \
  --args address:$PATIENT_ADDRESS string:"Initial treatment plan for heart condition. 10mg medication twice daily."
```

### Updating a Treatment Plan

```bash
aptos move run --function-id $ACCOUNT_ADDRESS::PatientTreatment::update_treatment \
  --args address:$PATIENT_ADDRESS string:"Updated treatment: 15mg medication once daily and physical therapy."
```

## 📊 Security Considerations

- All treatment data is stored on-chain and is therefore public. Design your implementation to avoid storing sensitive PII.
- Only the doctor who created a treatment plan can update it.
- Treatment records cannot be deleted, ensuring a complete and immutable history.

## 🔗 Future Enhancements

- Patient consent management
- Multi-doctor consultation functionality
- Advanced access control mechanisms
- Integration with off-chain healthcare systems
- Encrypted storage for sensitive data
- Analytics dashboard for treatment outcomes

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

*Built with ❤️ for better healthcare management on the blockchain* 