export type RegisterCompany = {
	address: {
		city: string, 
		zip: string, 
		street: string
	}, 
	company: {
		name: string,
		contact: string, 
		website?: string
	}, 
	password: string
}


export type QrCodeObject = {
		identifier: string,
		created: number,
		url: string,
		size: number,
		base64?: string
}