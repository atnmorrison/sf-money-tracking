global class DoubleUtils {

	public static String formatDouble(Double num, Integer decimalplaces) {

		Double multiplier = Math.pow(10, decimalplaces);
		num = num*multiplier;
		Long rounded = Math.roundToLong(num);
		num = rounded/multiplier;
		String formated = String.valueOf(num);

		//add zeros if needed
		Integer needed = decimalplaces - formated.substring(formated.indexOf('.')+1).length();
		for(Integer i=0; i <needed; i++) {
			formated += '0';
		}
		return formated;

	}

}