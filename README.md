# AutoChain VIN Registry

## Overview

AutoChain VIN Registry is a decentralized application built on the Stacks blockchain for tracking vehicle history using Vehicle Identification Numbers (VINs). It provides transparent and immutable record-keeping for vehicle ownership, service history, and maintenance records.

## Features

- Register vehicles with manufacturer, model, and year information
- Record detailed service history including maintenance, repairs, and accidents
- Transfer vehicle ownership securely on the blockchain
- Query complete vehicle history using VIN

## Use Cases

- Vehicle buyers can verify the complete history of a used car
- Service centers can add authenticated maintenance records
- Insurance companies can verify vehicle history
- Manufacturers can track recalls and service bulletins

## Smart Contract Functions

### Vehicle Registration

```clarity
(register-vehicle (vin (string-ascii 17)) (manufacturer (string-ascii 50)) (model (string-ascii 50)) (year uint))
```
