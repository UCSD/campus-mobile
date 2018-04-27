module.exports = {
	DINING_RESPONSE: [
		{
			'id': '01',
			'name': 'Pines',
			'description': 'This has an example of special hours.',
			'location': 'Muir College ',
			'address': '9500 Gilman Drive 0120, La Jolla, CA 92093-0120',
			'tel': '858.534.5167',
			'paymentOptions': [
				'Cash',
				'HDH Recharge'
			],
			'meals': 'breakfast, lunch, dinner',
			'persistentMenu': 'false',
			'images': [
				{
					'small': 'https://hdh2.ucsd.edu/_images/pines/inside1Small.png',
					'large': 'https://hdh2.ucsd.edu/_images/pines/inside1Large.png',
					'caption': 'Inside Pines'
				},
				{
					'small': 'https://hdh2.ucsd.edu/_images/pines/outsideSmall.png',
					'large': 'https://hdh2.ucsd.edu/_images/pines/outsideLarge.png',
					'caption': 'Outside Pines'
				},
				{
					'small': 'https://hdh2.ucsd.edu/_images/pines/pastaSmall.png',
					'large': 'https://hdh2.ucsd.edu/_images/pines/pastaLargeLarge.png',
					'caption': 'Pasta'
				},
				{
					'small': 'https://hdh2.ucsd.edu/_images/pines/saladbarSmall.png',
					'large': 'https://hdh2.ucsd.edu/_images/pines/saladbarLarge.png',
					'caption': 'Salad Bar'
				},
				{
					'small': 'https://hdh2.ucsd.edu/_images/pines/tacotrioSmall.png',
					'large': 'https://hdh2.ucsd.edu/_images/pines/tacotrioLarge.png',
					'caption': 'Taco Trio'
				}
			],
			'coords': {
				'lat': '32.8754115',
				'lon': '-117.242701'
			},
			'regularHours': {
				'mon': '0730-2100',
				'tue': '0730-0900,1015-1100',
				'wed': '0730-1800',
				'thu': '0730-2100',
				'fri': '0730-0900',
				'sat': '1000-2000',
				'sun': '0800-1100,1900-0100'
			},
			'specialHours': {
				'02/26/2018': {
					'title': 'This is a test of a very long title. One two three four five six seven',
					'hours': '0800-0900,1000-1100,1200-1300,1400-1500'
				},
				'12/25/2018': {
					'title': 'Christmas',
					'hours': null
				}
			}
		},
		{
			'id': '02',
			'name': 'Open 24 Hours',
			'description': 'This place is open 24 hours except on weekends.',
			'location': 'Muir College, 1st Floor of Tamarack Apartments',
			'address': '9500 Gilman Drive 0120, La Jolla, CA 92093-0120',
			'tel': '858.822.7729',
			'paymentOptions': [
				'Cash',
				'Check'
			],
			'meals': null,
			'persistentMenu': null,
			'images': [
				{
					'small': 'https://hdh2.ucsd.edu/_images/johnsmarket/inside1Small.png',
					'large': 'https://hdh2.ucsd.edu/_images/johnsmarket/inside1Large.png',
					'caption': 'Inside Johns Market'
				},
				{
					'small': 'https://hdh2.ucsd.edu/_images/johnsmarket/inside2Small.png',
					'large': 'https://hdh2.ucsd.edu/_images/johnsmarket/inside2Large.png',
					'caption': 'Inside Johns Market'
				},
				{
					'small': 'https://hdh2.ucsd.edu/_images/johnsmarket/inside3Small.png',
					'large': 'https://hdh2.ucsd.edu/_images/johnsmarket/inside3Large.png',
					'caption': 'Inside Johns Market'
				},
				{
					'small': 'https://hdh2.ucsd.edu/_images/johnsmarket/outside1Small.png',
					'large': 'https://hdh2.ucsd.edu/_images/johnsmarket/outside1Large.png',
					'caption': 'Outside Johns Market'
				}
			],
			'coords': {
				'lat': '32.8794045',
				'lon': '-117.242369'
			},
			'regularHours': {
				'mon': '0000-2359',
				'tue': '0000-2359',
				'wed': '0000-2358',
				'thu': '0000-2359',
				'fri': '0000-2359',
				'sat': null,
				'sun': null
			},
			'specialHours': null
		}
	]
};
