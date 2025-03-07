;; Entanglement Network Difficulty Adjustment Contract

(define-map difficulty-levels
  { cycle-id: uint }
  {
    base-difficulty: uint,
    entanglement-factor: uint,
    active-miners: uint
  }
)

(define-public (set-difficulty (cycle-id uint) (base-difficulty uint) (entanglement-factor uint))
  (ok (map-set difficulty-levels
    { cycle-id: cycle-id }
    {
      base-difficulty: base-difficulty,
      entanglement-factor: entanglement-factor,
      active-miners: u0
    }
  ))
)

(define-public (register-active-miner (cycle-id uint))
  (match (map-get? difficulty-levels { cycle-id: cycle-id })
    difficulty
      (ok (map-set difficulty-levels
        { cycle-id: cycle-id }
        (merge difficulty { active-miners: (+ (get active-miners difficulty) u1) })
      ))
    (err u404)
  )
)

(define-read-only (get-difficulty (cycle-id uint))
  (match (map-get? difficulty-levels { cycle-id: cycle-id })
    difficulty
      (let
        ((base (get base-difficulty difficulty))
         (factor (get entanglement-factor difficulty))
         (miners (get active-miners difficulty)))
        (+ base (* factor miners)))
    u1000  ;; Default difficulty if not set
  )
)

(define-read-only (get-difficulty-info (cycle-id uint))
  (map-get? difficulty-levels { cycle-id: cycle-id })
)

