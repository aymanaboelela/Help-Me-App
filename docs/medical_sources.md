# Medical sources

Every piece of first-aid guidance in this app traces to a published lay-rescuer standard. This
file exists so a clinician reviewing the content has something concrete to check against, rather
than having to infer intent from prose.

**The app is written by a developer, not a clinician.** Where guidance differs between bodies, the
app teaches the simpler action that is safe under both.

## Standards followed

- **ERC** — European Resuscitation Council Guidelines, Basic Life Support and Paediatric Life
  Support chapters.
- **AHA** — American Heart Association Guidelines for CPR and ECC, lay-rescuer sequences.
- **WHO** — oral rehydration therapy for diarrhoea in children.

## Paediatric content added in 4.0 phase A

| Topic / variant | Standard | Key points a reviewer should check |
| --- | --- | --- |
| `cpr` · child | ERC Paediatric BLS | Five initial rescue breaths; one or two hands; ~5 cm, one third of chest depth; 30:2 for a lone lay rescuer; paediatric AED pads preferred, adult pads acceptable. |
| `cpr` · infant | ERC Paediatric BLS | Neutral head position; mouth-and-nose seal; two fingers; ~4 cm, one third of chest depth; five initial breaths; 30:2; never shake a baby. |
| `choking` · child | ERC / AHA | Five back blows then five abdominal thrusts; no blind finger sweep; medical review after abdominal thrusts. |
| `choking` · infant | ERC / AHA | Back blows and **chest** thrusts only; abdominal thrusts contraindicated under one year; same-day medical check even after success. |
| `drowning` · child & infant | ERC | Five initial rescue breaths; no attempt to drain water; hospital assessment for every rescued child; rapid cooling risk. |
| `burns` · child & infant | ERC / burn-care consensus | 20 minutes cool running water; hypothermia risk during cooling; palm-size threshold; any burn on an infant reviewed; no ice, butter, toothpaste or flour. |
| `anaphylaxis` · child | ERC / auto-injector labelling | 0.15 mg under 30 kg, 0.3 mg over; outer thigh; supine with legs raised; second dose at 5 minutes; never stand them up; antihistamine is not a treatment. |
| `seizures` · child | ERC / epilepsy first-aid consensus | Time it; side position; no restraint; nothing in the mouth; five-minute ambulance threshold; points at `febrile_seizure` for the full procedure. |
| `febrile_seizure` | Paediatric febrile-convulsion consensus | 6 months to 5 years; no restraint; nothing in the mouth; no cooling baths; five-minute threshold; meningitis red flags; antipyretics do not prevent recurrence. |
| `child_dehydration` | WHO oral rehydration therapy | One sachet per 1 litre clean water, exactly; small frequent volumes; continue breastfeeding; no anti-diarrhoeals in children; juice and soft drinks make it worse. |
| `swallowed_object` | Paediatric GI foreign-body consensus | Button battery as a same-day emergency; multiple magnets; sharps; coin needing imaging; inhaled nut; nothing by mouth; never induce vomiting. |

## Deliberate omissions

- **No weight-based dosing calculator.** The app names the two auto-injector strengths because they
  are printed on the devices themselves. It does not compute paracetamol or any other dose.
- **No guidance for anaphylaxis in a baby under about 7.5 kg**, where the dose is a clinician's
  decision. The topic says so and directs to the ambulance service.
- **No wound photography**, unchanged from the 3.0 decision.

## Review status

- [ ] Reviewed by a paediatrician before store release.
