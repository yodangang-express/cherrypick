import type { MiNote } from '@/models/Note.js';
import { MiUser } from '@/models/User.js';

const moderators: string[] = process.env.MODERATORS?.split(',') ?? [];

export function anonymizeNote(note: MiNote | any, maskingContents = false, meId: string | null = ''): void {
	if (moderators.includes(meId ?? '')) {
		return note;
	}

	note.user = anonymousUser();
	note.userId = 'anonymous';
	note.cw = null;
	note.fileIds = [];
	note.files = [];
	note.replyUserId = note.replyUserId ? 'anonymous' : null;
	note.renoteUserId = note.replyUserId ? 'anonymous' : null;
	note.mentions = [];

	if (maskingContents) {
		note.text = '(Unauthorized)';
	}

	if (note.renote) {
		anonymizeNote(note.renote, maskingContents);
	}

	if (note.reply) {
		anonymizeNote(note.reply, maskingContents);
	}
}

export function anonymousUser() {
	return new MiUser({
		id: 'anonymous',
		username: 'anonymous',
		usernameLower: 'anonymous',
		tags: [],
		emojis: [],
		avatarDecorations: [],
	});
}
