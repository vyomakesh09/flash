# Aave Flash Loan Implementation

This project implements flash loans using the Aave V3 Protocol. It provides a base contract for executing flash loans and handling the required callbacks.

## Features

- Multi-asset flash loans
- Built-in safety checks
- Gas efficient implementation
- Follows Aave V3 standards

## Usage

1. Deploy the FlashLoan contract with the address of the Aave V3 Pool for your network
2. Implement your custom logic in the executeOperation function
3. Call requestFlashLoan with the assets and amounts you want to borrow

## Contract Addresses

### Ethereum Mainnet
- Aave V3 Pool: `0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2`

### Polygon
- Aave V3 Pool: `0x794a61358D6845594F94dc1DB02A252b5b4814aD`

## Security Considerations

- Never store funds permanently in the flash loan contract
- Always ensure sufficient funds are available for repayment
- Validate that the caller of executeOperation is the Aave Pool
- Test extensively before mainnet deployment

## License

MIT
