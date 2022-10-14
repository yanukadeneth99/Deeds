;; --- Deed Contract ---
;; This contract contains information on house deeds which can be created and listed
;; by anyone. The listed deeds can be bought and sold by other parties. Every
;; interaction is handled from this contract itself and cannot involve another
;; party.

;; --- Constants ---
;;

;; --- Data Vars ---

;; --- Data Maps ---
;; Deed ID => HouseInformation(owner, first name, image url, metadata(bedrooms, bathrooms, size X, size Y), price of the house, whether it's listed for sale)
(define-map deeds uint { owner: principal, name: (string-ascii 15), images: (string-ascii 128), metadata: (list 4 uint), price: uint, listed: bool })

;; --- Private Functions ---
;;

;; --- Public Functions ---

;; Create Deed

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
