;; AutoChain VIN Registry
;; A decentralized vehicle identification number (VIN) registry for tracking vehicle history

(define-data-var admin principal tx-sender)

;; Map of VIN to vehicle data
(define-map vehicles
  {vin: (string-ascii 17)}
  {
    owner: principal,
    manufacturer: (string-ascii 50),
    model: (string-ascii 50),
    year: uint,
    last-update: uint
  }
)

;; Map of VIN to service history entries
(define-map service-history
  {vin: (string-ascii 17), entry-id: uint}
  {
    service-date: uint,
    mileage: uint,
    service-type: (string-ascii 100),
    service-provider: principal,
    notes: (string-ascii 500)
  }
)

;; Map to track the number of service entries per VIN
(define-map service-entry-count
  {vin: (string-ascii 17)}
  {count: uint}
)

;; Data variable to track current block for testing purposes
(define-data-var current-block uint u0)

;; Function to register a new vehicle
(define-public (register-vehicle 
                (vin (string-ascii 17)) 
                (manufacturer (string-ascii 50)) 
                (model (string-ascii 50)) 
                (year uint))
  (let ((exists (map-get? vehicles {vin: vin}))
        (curr-block (var-get current-block)))
    (asserts! (is-none exists) (err u1)) ;; Error code 1: VIN already registered
    (map-set vehicles 
      {vin: vin} 
      {
        owner: tx-sender,
        manufacturer: manufacturer,
        model: model,
        year: year,
        last-update: curr-block
      }
    )
    (map-set service-entry-count {vin: vin} {count: u0})
    (ok true)
  )
)

;; Function to add a service record
(define-public (add-service-record 
                (vin (string-ascii 17)) 
                (service-date uint) 
                (mileage uint) 
                (service-type (string-ascii 100)) 
                (notes (string-ascii 500)))
  (let ((vehicle (map-get? vehicles {vin: vin}))
        (entry-count-data (default-to {count: u0} (map-get? service-entry-count {vin: vin})))
        (entry-count (get count entry-count-data))
        (curr-block (var-get current-block)))
    (asserts! (is-some vehicle) (err u2)) ;; Error code 2: Vehicle not found
    (asserts! (or (is-eq tx-sender (get owner (unwrap-panic vehicle))) 
                  (is-eq tx-sender (var-get admin))) 
              (err u3)) ;; Error code 3: Not authorized
    
    (map-set service-history 
      {vin: vin, entry-id: entry-count} 
      {
        service-date: service-date,
        mileage: mileage,
        service-type: service-type,
        service-provider: tx-sender,
        notes: notes
      }
    )
    (map-set service-entry-count {vin: vin} {count: (+ entry-count u1)})
    (map-set vehicles 
      {vin: vin} 
      (merge (unwrap-panic vehicle) {last-update: curr-block})
    )
    (ok entry-count)
  )
)

;; Function to transfer vehicle ownership
(define-public (transfer-ownership (vin (string-ascii 17)) (new-owner principal))
  (let ((vehicle (map-get? vehicles {vin: vin}))
        (curr-block (var-get current-block)))
    (asserts! (is-some vehicle) (err u2)) ;; Error code 2: Vehicle not found
    (asserts! (is-eq tx-sender (get owner (unwrap-panic vehicle))) (err u3)) ;; Error code 3: Not authorized
    
    (map-set vehicles 
      {vin: vin} 
      (merge (unwrap-panic vehicle) 
             {
               owner: new-owner,
               last-update: curr-block
             }
      )
    )
    (ok true)
  )
)

;; Function to update the current block (for testing purposes)
(define-public (update-block (new-block uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u3)) ;; Error code 3: Not authorized
    (var-set current-block new-block)
    (ok true)
  )
)

;; Read-only function to get vehicle information
(define-read-only (get-vehicle-info (vin (string-ascii 17)))
  (map-get? vehicles {vin: vin})
)

;; Read-only function to get service history entry
(define-read-only (get-service-entry (vin (string-ascii 17)) (entry-id uint))
  (map-get? service-history {vin: vin, entry-id: entry-id})
)

;; Read-only function to get service entry count
(define-read-only (get-service-count (vin (string-ascii 17)))
  (default-to {count: u0} (map-get? service-entry-count {vin: vin}))
)

;; Read-only function to get current block
(define-read-only (get-current-block)
  (var-get current-block)
)