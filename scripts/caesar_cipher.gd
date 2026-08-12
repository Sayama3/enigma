extends Node

func encode(text: String, shift: int) -> String:
	var result := ""
	
	for i in range(text.length()):
		var c := text[i]
		var code := c.unicode_at(0)
		
		if c >= "a" and c <= "z":
			code = (code - 97 + shift) % 26
			if code < 0:
				code += 26
			result += char(code + 97)
		elif c >= "A" and c <= "Z":
			code = (code - 65 + shift) % 26
			if code < 0:
				code += 26
			result += char(code + 65)
		else:
			result += c
	
	return result

func decode(text: String, shift: int) -> String:
	return encode(text, -shift)
	
func _ready() -> void:
	var message := "Hello, World!"
	var encrypted := encode(message, 3)
	var decrypted := decode(encrypted, 3)
	
	print("Original : ", message)
	print("Chiffré  : ", encrypted)
	print("Déchiffré: ", decrypted)
