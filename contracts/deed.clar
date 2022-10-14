;; --- Deed Contract ---
;; This contract contains information on house deeds which can be created and listed
;; by anyone. The listed deeds can be bought and sold by other parties. Every
;; interaction is handled from this contract itself and cannot involve another
;; party.

;; --- Errors ---
(define-constant err-deed-not-listed (err u100)) ;; Deed is not listed for sale
(define-constant err-deed-listed (err u101)) ;; Deed is listed for sale
(define-constant err-deed-does-not-exist (err u102)) ;; Deed does not exist
(define-constant err-deed-exists (err u103)) ;; Deed already exists
(define-constant err-invalid-variable (err u104)) ;; Invalid Value Passed


;; --- Constants ---
;; Owner
(define-constant contract-owner tx-sender)

;; --- Data Vars ---
;; Last Deed ID value
(define-data-var last-deed-id uint u0)

;; --- Data Maps ---
;; Deed ID => HouseInformation(owner, first name, image url, metadata(bedrooms, bathrooms, size X, size Y), price of the house, whether it's listed for sale)
(define-map deeds uint { owner: principal, name: (string-ascii 15), images: (string-ascii 128), metadata: (list 4 uint), price: uint, listed: bool })

;; --- Private Functions ---
;;

;; --- Public Functions ---

;; Creates a Deed
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
      (metadata (list bedroom bathroom sizeX sizeY))
    )
    (asserts! (is-eq (> bedroom u0)) err-invalid-variable)
    (asserts! (is-eq (> bathroom u0)) err-invalid-variable)
    (asserts! (is-eq (> sizeX u0)) err-invalid-variable)
    (asserts! (is-eq (> sizeY u0)) err-invalid-variable)
    (map-set deeds next-deed-id {owner: tx-sender, name: name, images: images, metadata: metadata, price: u0, listed: false })
    (ok true)
  )
)

;; Update Deed

;; List for Sale

;; Unlist for Sale

;; Buy House

;; Change Price

;; Change Images

;; Change Name

;; Change Metadata



;; Gets the current owner of the Deed ID
;; @param deed-id The uint Deed ID you want to check
;; @returns tuple {principal owner, string-ascii 15 name}
(define-public (get-owner (deed-id uint))
  (let
    (
      (owner (get owner (map-get? deeds deed-id)))
      (name (get name (map-get? deeds deed-id)))
    )
    (ok {owner: owner, name: name})
  )
)
