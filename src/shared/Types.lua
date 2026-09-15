--!strict
export type Villain = {
	Name: string,
	World: number,
	CostHeists: number?,
	PowerPerClick: number?,
	Desc: string,
	Palette: string,
	Robux: number?,
	IsBestMultiplier: boolean?,
}

export type World = {
	Id: number,
	Name: string,
	GateHeists: number,
	GateInfamy: number,
	Color: Color3,
	Position: Vector3,
	TrainingMultiplier: number,
}

export type PlayerData = {
	Infamy: number,
	Heists: number,
	Tokens: number,
	Rebirths: number,
	EquippedVillain: string,
	OwnedVillains: { string },
	EquippedHenchmen: { string },
	OwnedHenchmen: { string },
	CurrentWorld: number,
	HighestLevel: number,
}

return {}
