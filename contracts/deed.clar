;;* --- Deed Contract ---
;; This contract contains information on house deeds which can be created and listed
;; by anyone. The listed deeds can be bought and sold by other parties. Every
;; interaction is handled from this contract itself and cannot involve another
;; party (human).

;;? --- Errors ---
(define-constant err-deed-not-listed (err u100)) ;; Deed is not listed for sale
(define-constant err-deed-listed (err u101)) ;; Deed is listed for sale
(define-constant err-deed-does-not-exist (err u102)) ;; Deed does not exist
(define-constant err-deed-exists (err u103)) ;; Deed already exists
(define-constant err-invalid-variable (err u104)) ;; Invalid Value in a Tuple
(define-constant err-not-deed-owner (err u105)) ;; Not the Deed Owner
(define-constant err-price-expected-more (err u106)) ;; Price is zero or not enough


;;? --- Constants ---
;; Owner
(define-constant contract-owner tx-sender)

;;? --- Data Vars ---
;; Last Deed ID value
(define-data-var last-deed-id uint u0)

;;? --- Data Maps ---
;; Deed ID => HouseInformation(owner, first name, image url, bedrooms, bathrooms, Land Width, Land Length, price of the house, whether it's listed for sale)
(define-map deeds uint { owner: principal, name: (string-ascii 15), images: (string-ascii 128), bedroom: uint, bathroom: uint, sizeX: uint, sizeY: uint, price: uint, listed: bool })

;;? --- Private Functions ---
;;* Returns True if the caller is the owner of the Deed ID
;; @dev Throws if the deed does not exist
(define-private (is-valid-owner (deed-id uint)) 
  (let
    (
      (owner (unwrap! (get owner (map-get? deeds deed-id)) err-deed-does-not-exist))
    )
  (ok (is-eq (unwrap-panic (get owner (map-get? deeds deed-id))) tx-sender))
  )
)

;;? --- Public Functions ---

;;* Creates a Deed
;; @param name Your name
;; @param images A IPFS or HTTPS Link to images
;; @param bedroom Number of bedrooms
;; @param bathroom Number of bathrooms
;; @param sizeX The Width of the land of the House
;; @param sizeY The Length of the land of the House
;; @returns bool True if all is good
(define-public (create-deed (name (string-ascii 15)) (images (string-ascii 128)) (bedroom uint) (bathroom uint) (sizeX uint) (sizeY uint))
  (let
    (
      (next-deed-id (+ (var-get last-deed-id) u1))
    )
    (asserts! (> bedroom u0) err-invalid-variable)
    (asserts! (> bathroom u0) err-invalid-variable)
    (asserts! (> sizeX u0) err-invalid-variable)
    (asserts! (> sizeY u0) err-invalid-variable)
    (asserts! (not (is-eq images "")) err-invalid-variable)
    (asserts! (not (is-eq name "")) err-invalid-variable)
    (map-set deeds next-deed-id {owner: tx-sender, name: name, images: images, bedroom: bedroom, bathroom: bathroom, sizeX: sizeX, sizeY: sizeY, price: u0, listed: false })
    (ok true)
  )
)

;;* Transfers an existing owned Deed
;; @param recipient Transfer person ID
;; @param deed-id The Deed ID
;; @returns bool True if all is good
(define-public (transfer-deed (recipient principal) (deed-id uint))
  (begin
    (asserts! (try! (is-valid-owner deed-id)) err-not-deed-owner)
    (map-set deeds deed-id (merge (unwrap-panic (map-get? deeds deed-id)) {owner: recipient}))
    (ok true)
  )
)

;;* Listing owned Deed for sale
;; @dev No need to check as it's all done within the programme
;; @param deed-id The ID of the Deed
;; @param price The price you want to sell the house for
;; @returns bool True if all is good
(define-public (list-for-sale (deed-id uint) (price uint))
  (begin
    (asserts! (try! (is-valid-owner deed-id)) err-not-deed-owner)
    (asserts! (not (unwrap-panic (get listed (map-get? deeds deed-id)))) err-deed-listed)
    (asserts! (> price u0) err-price-expected-more)
    (map-set deeds deed-id (merge (unwrap-panic (map-get? deeds deed-id)) {listed: true, price: price}))
    (ok true)
  )
)

;;* Unlist a deed from sale
;; @param deed-id The Deed ID
;; @returns bool True if all is good
(define-public (unlist-for-sale (deed-id uint))
  (begin
    (asserts! (try! (is-valid-owner deed-id)) err-not-deed-owner)
    (asserts! (unwrap-panic (get listed (map-get? deeds deed-id))) err-deed-listed)
    (map-set deeds deed-id (merge (unwrap-panic (map-get? deeds deed-id)) {listed: false}))
    (ok true)
  )
)

;;* Buy House
;; @param deed-id The Deed ID
;; @dev PAYABLE - Need to pay to buy
;; @returns bool True if all is good
(define-public (buy-deed (deed-id uint))
  (let
    (
      (owner (unwrap! (get owner (map-get? deeds deed-id)) err-deed-does-not-exist))
      (listed (unwrap-panic (get listed (map-get? deeds deed-id))))
      (price (unwrap-panic (get price (map-get? deeds deed-id))))
    )
    (asserts! listed err-deed-not-listed)
    (asserts! (is-eq (> price u0)) err-price-expected-more)
    (try! (stx-transfer? price tx-sender owner)) ;; Transaction from the buyer to the owner
    (map-set deeds deed-id (merge (unwrap-panic (map-get? deeds deed-id)) {owner: tx-sender, listed: false}))
    (ok true)
  )
)

;;* Change the price of an owned deed
;; @param deed-id The Deed ID
;; @param new-price The New price you want to replace the deed with
;; @returns bool True if all is good
(define-public (change-price (deed-id uint) (new-price uint))
  (begin
    (asserts! (try! (is-valid-owner deed-id)) err-not-deed-owner)
    (asserts! (> new-price u0) err-price-expected-more)
    (map-set deeds deed-id (merge (unwrap-panic (map-get? deeds deed-id)) {price: new-price}))
    (ok true)
  )
)

;;* Change the image URL of an owned deed
;; @param deed-id The Deed ID
;; @param new-images The New image URL you want to replace the deed with
;; @returns bool True if all is good
(define-public (change-images (deed-id uint) (new-images (string-ascii 128)))
  (begin
    (asserts! (try! (is-valid-owner deed-id)) err-not-deed-owner)
    (asserts! (not (is-eq new-images "")) err-invalid-variable)
    (map-set deeds deed-id (merge (unwrap-panic (map-get? deeds deed-id)) {images: new-images}))
    (ok true)
  )
)

;;* Change the user name of an owned deed
;; @param deed-id The Deed ID
;; @param new-name The New name you want to replace the deed with
;; @returns bool True if all is good
(define-public (change-name (deed-id uint) (new-name (string-ascii 15)))
  (begin
    (asserts! (try! (is-valid-owner deed-id)) err-not-deed-owner)
    (asserts! (not (is-eq new-name "")) err-invalid-variable)
    (map-set deeds deed-id (merge (unwrap-panic (map-get? deeds deed-id)) {name: new-name}))
    (ok true)
  )
)

;;* Change the bedroom count of an owned deed
;; @param deed-id The Deed ID
;; @param new-bedroom The Bedroom count you want to replace the deed with
;; @returns bool True if all is good
(define-public (change-bedroom (deed-id uint) (new-bedroom uint)) 
  (begin
    (asserts! (try! (is-valid-owner deed-id)) err-not-deed-owner)
    (asserts! (> new-bedroom u0) err-invalid-variable)
    (map-set deeds deed-id (merge (unwrap-panic (map-get? deeds deed-id)) {bedroom: new-bedroom}))
    (ok true)
  )
)

;;* Change the bathroom count of an owned deed
;; @param deed-id The Deed ID
;; @param new-bathroom The Bedroom count you want to replace the deed with
;; @returns bool True if all is good
(define-public (change-bathroom (deed-id uint) (new-bathroom uint)) 
  (begin
    (asserts! (try! (is-valid-owner deed-id)) err-not-deed-owner)
    (asserts! (> new-bathroom u0) err-invalid-variable)
    (map-set deeds deed-id (merge (unwrap-panic (map-get? deeds deed-id)) {bathroom: new-bathroom}))
    (ok true)
  )
)

;;* Change the size of an owned deed
;; @param deed-id The Deed ID
;; @param new-sizeX The New Land Width of the land of the house
;; @param new-sizeY The New Land Length of the land of the house
;; @returns bool True if all is good
(define-public (change-size (deed-id uint) (new-sizeX uint) (new-sizeY uint)) 
  (begin
    (asserts! (try! (is-valid-owner deed-id)) err-not-deed-owner)
    (asserts! (> new-sizeX u0) err-invalid-variable)
    (asserts! (> new-sizeY u0) err-invalid-variable)
    (map-set deeds deed-id (merge (unwrap-panic (map-get? deeds deed-id)) {sizeX: new-sizeX, sizeY: new-sizeY}))
    (ok true)
  )
)

;;* Gets the passed deed information
;; @param deed-id The uint Deed ID you want to check
;; @returns tuple {principal owner, string-ascii 15 name}
;; OR (Depending on whether deed is listed for sale)
;; @returns tuple {principal owner, string-ascii 15 name, uint bedroom, uint bathroom, uint sizeX, uint sizeY, string-ascii 120 images, uint price}
(define-read-only (get-deed (deed-id uint))
  (let
    (
      (owner (unwrap! (get owner (map-get? deeds deed-id)) err-deed-does-not-exist))
      (name (unwrap-panic (get name (map-get? deeds deed-id))))
      (listed (unwrap-panic (get listed (map-get? deeds deed-id))))
      (bedroom (unwrap-panic (get bedroom (map-get? deeds deed-id))))
      (bathroom (unwrap-panic (get bathroom (map-get? deeds deed-id))))
      (sizeX (unwrap-panic (get sizeX (map-get? deeds deed-id))))
      (sizeY (unwrap-panic (get sizeY (map-get? deeds deed-id))))
      (images (unwrap-panic (get images (map-get? deeds deed-id))))
      (price (unwrap-panic (get price (map-get? deeds deed-id))))
    )
    (if (not listed)
      ;; Not listed - Return the owner and name
      (ok {owner: owner, name: name})

      ;; Listed - Returns all the information to view
      (ok {owner: owner, name: name, bedroom: bedroom, bathroom: bathroom, sizeX: sizeX, sizeY: sizeY, images: images, price: price})
    )
  )
)

;;* Gets the owner of a deed
;; @param deed-id The Deed ID
;; @returns principal The Owner address of the Deed
(define-read-only (get-owner (deed-id uint))
  (ok (unwrap! (get owner (map-get? deeds deed-id)) err-deed-does-not-exist))
)
