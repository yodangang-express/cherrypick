/**
 * Module dependencies
 */
import it from 'cafy';
import User from '../../models/user';
import serialize from '../../serializers/user';
import getFriends from '../../common/get-friends';

/**
 * Get recommended users
 *
 * @param {any} params
 * @param {any} me
 * @return {Promise<any>}
 */
module.exports = (params, me) => new Promise(async (res, rej) => {
	// Get 'limit' parameter
	const [limit = 10, limitErr] = it(params.limit).expect.number().range(1, 100).get();
	if (limitErr) return rej('invalid limit param');

	// Get 'offset' parameter
	const [offset = 0, offsetErr] = it(params.offset).expect.number().min(0).get();
	if (offsetErr) return rej('invalid offset param');

	// ID list of the user itself and other users who the user follows
	const followingIds = await getFriends(me._id);

	const users = await User
		.find({
			_id: {
				$nin: followingIds
			}
		}, {
			limit: limit,
			skip: offset,
			sort: {
				followers_count: -1
			}
		});

	// Serialize
	res(await Promise.all(users.map(async user =>
		await serialize(user, me, { detail: true }))));
});
