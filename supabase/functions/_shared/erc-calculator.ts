// =============================================
// SPO - Effective Real Cost (ERC) Calculator
// Core business logic for benefit optimization
// =============================================

export interface CardInfo {
  name: string;
  domestic_pts_per_dollar: number;
  intl_pts_per_dollar: number;
  points_program: string;
  cashback_percentage?: number;
}

export interface LoyaltyProgram {
  id: string;
  name: string;
  code: string;
  value_per_1000_miles: number;
}

export interface TransferBonus {
  bank_name: string;
  loyalty_program_id: string;
  bonus_percentage: number;
}

export interface CashbackProgram {
  name: string;
  percentage: number;
}

export interface ERCCalculationInput {
  store_price: number;
  card: CardInfo;
  loyalty_program: LoyaltyProgram;
  transfer_bonus?: TransferBonus;
  cashback_program?: CashbackProgram;
  exchange_rate_usd_brl: number;
  is_international?: boolean;
  promo_pts?: number; // Bonus points per dollar from promotion
}

export interface ERCCalculationResult {
  erc: number;
  store_price: number;
  cashback_amount: number;
  miles_value: number;
  transfer_bonus_value: number;
  total_benefits: number;
  breakdown: {
    price_store: number;
    cashback_deduction: number;
    points_earned: number;
    miles_after_bonus: number;
    mile_value: number;
    miles_deduction: number;
  };
  recommendation: string;
}

/**
 * Calculate Effective Real Cost (ERC)
 * 
 * Formula:
 * ERC = Price_Store - (Price_Store × %CB) - 
 *       (((Price_Store / Rate_USD) × Pts_Card) + (Price_Store × Pts_Promo)) / 1000 
 *       × Value_Mile × (1 + %Bonus)
 */
export function calculateERC(input: ERCCalculationInput): ERCCalculationResult {
  const {
    store_price,
    card,
    loyalty_program,
    transfer_bonus,
    cashback_program,
    exchange_rate_usd_brl,
    is_international = false,
    promo_pts = 0,
  } = input;

  // 1. Cashback deduction
  const cashback_pct = cashback_program?.percentage ?? 0;
  const cashback_amount = store_price * (cashback_pct / 100);

  // 2. Points earned based on card rate (domestic vs intl)
  const pts_per_dollar = is_international
    ? card.intl_pts_per_dollar
    : card.domestic_pts_per_dollar;

  const points_from_card = (store_price / exchange_rate_usd_brl) * pts_per_dollar;
  const points_from_promo = store_price * promo_pts;
  const total_points = points_from_card + points_from_promo;

  // 3. Transfer bonus calculation
  const bonus_pct = transfer_bonus?.bonus_percentage ?? 0;
  const miles_after_bonus = total_points * (1 + bonus_pct / 100);

  // 4. Mile value calculation
  const mile_value_brl = loyalty_program.value_per_1000_miles / 1000;
  const miles_deduction = miles_after_bonus * mile_value_brl;

  // 5. Final ERC
  const erc = store_price - cashback_amount - miles_deduction;

  // 6. Total benefits
  const total_benefits = cashback_amount + miles_deduction;

  // 7. Generate recommendation
  const recommendation = generateRecommendation(
    erc,
    store_price,
    total_benefits,
    cashback_pct,
    miles_after_bonus,
    loyalty_program.name
  );

  return {
    erc: Math.round(erc * 100) / 100,
    store_price,
    cashback_amount: Math.round(cashback_amount * 100) / 100,
    miles_value: Math.round(miles_deduction * 100) / 100,
    transfer_bonus_value: Math.round(
      (total_points * (bonus_pct / 100) * mile_value_brl) * 100
    ) / 100,
    total_benefits: Math.round(total_benefits * 100) / 100,
    breakdown: {
      price_store: store_price,
      cashback_deduction: cashback_amount,
      points_earned: Math.round(total_points),
      miles_after_bonus: Math.round(miles_after_bonus),
      mile_value: loyalty_program.value_per_1000_miles,
      miles_deduction: Math.round(miles_deduction * 100) / 100,
    },
    recommendation,
  };
}

/**
 * Rank multiple purchase scenarios and return best options
 */
export function rankScenarios(
  inputs: ERCCalculationInput[]
): ERCCalculationResult[] {
  return inputs
    .map(calculateERC)
    .sort((a, b) => a.erc - b.erc); // Lower ERC = better deal
}

/**
 * Determine optimal card based on user goal
 */
export function selectOptimalCard(
  cards: CardInfo[],
  goal: 'CASH' | 'FAMILY' | 'LUXURY'
): CardInfo {
  switch (goal) {
    case 'CASH':
      // Maximize domestic points accumulation
      return cards.reduce((best, card) =>
        card.domestic_pts_per_dollar > best.domestic_pts_per_dollar ? card : best
      );
    case 'FAMILY':
      // Balance points and value (Azul/Smiles for volume)
      return cards.reduce((best, card) =>
        card.domestic_pts_per_dollar >= 4 ? card : best
      );
    case 'LUXURY':
      // Maximize value per point (Centurion for Accor/Iberia)
      return cards.find(c => c.name === 'Amex Centurion') ?? cards[0];
    default:
      return cards[0];
  }
}

function generateRecommendation(
  erc: number,
  store_price: number,
  total_benefits: number,
  cashback_pct: number,
  miles: number,
  loyalty_name: string
): string {
  const savings_pct = ((store_price - erc) / store_price) * 100;

  if (savings_pct > 30) {
    return `EXCELLENT DEAL! Save ${savings_pct.toFixed(1)}% with ${loyalty_name} + ${cashback_pct}% cashback. Earn ${Math.round(miles)} miles.`;
  } else if (savings_pct > 20) {
    return `GOOD VALUE! Save ${savings_pct.toFixed(1)}% using ${loyalty_name}. Total benefits: R$${total_benefits.toFixed(2)}`;
  } else if (savings_pct > 10) {
    return `MODERATE savings of ${savings_pct.toFixed(1)}%. Consider ${loyalty_name} transfer.`;
  }
  return `Standard pricing. Benefits: R$${total_benefits.toFixed(2)}`;
}
